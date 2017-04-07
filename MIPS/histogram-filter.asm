.data
	input_file: .asciiz "input.bmp"
	output_file: .asciiz "input-out.bmp"
	.align 2
	buffer: .space 256
	size: .space 4
	width: .space 4
	height: .space 4
	soffset: .space 4
	colorBits: .space 4
	hR: .space 1024
	hG: .space 1024
	hB: .space 1024
.text
#############################################################################
#REGISTER DESCRIPRTION
# s0 - file handle
# s1 - size
# s2 - width
# s3 - height	
# s4 - fileBufferAddress
#############################################################################
	#open file
	li $v0, 13 #call file open
	la $a0, input_file #input file name
	li $a1, 0 # open in readmode
	li $a2, 0 #no special mode
	syscall
	move $s0, $v0 #save file descripter
	# read bmp 16 byte header
	move $a0, $s0
	li $v0, 14
	la $a1, buffer
	li $a2, 2
	syscall #read BM bytes -TODO - verify if BM type
	#BMP HEADER#
	la $a1, size
	li $v0, 14
	li $a2, 4
	syscall #read image size
	lw $s1, size
	
	move $a0, $s0
	la $a1, buffer
	li $v0, 14
	li $a2, 4 #skip first 4 bytes
	syscall
	la $a1, soffset
	li $v0, 14
	li $a2, 4
	syscall #read image start offset
	#DETAILED HEADER#
	move $a0, $s0
	la $a1, buffer
	li $v0, 14
	li $a2, 4 
	syscall # header size
	la $a1, width
	li $v0, 14
	li $a2, 4 
	syscall # load width
	lw $s2, width
	
	la $a1, height
	li $v0, 14
	li $a2, 4 
	syscall # load height
	lw $s3, height
	
	la $a1, buffer
	li $v0, 14
	li $a2, 2
	syscall# skip color planes info
	la $a1, colorBits
	sw $0, 0($a1) #clear 4 bytes
	li $v0, 14
	li $a2, 2
	syscall#read bits per pixel
	la $a0, colorBits
	lw $a0, 0($a0)
	li $v0, 1 
	syscall #print color bits per pixel
	
	
fclose:
	#close the file
	li $v0, 16
	move $a0, $s0
	syscall
#reload the file and buffer it in memory
	move $a0, $s1
	li $v0, 9
	syscall # allocate file buffer
	move $s4, $v0
	
	#open file
	li $v0, 13 #call file open
	la $a0, input_file #input file name
	li $a1, 0 # open in readmode
	li $a2, 0 #no special mode
	syscall	
	move $s0, $v0
	
	#read file into memory buffer
	move $a0, $s0
	move $a1, $s4
	li $v0, 14
	move $a2, $s1
	syscall # read whole file
	#close the file
	li $v0, 16
	move $a0, $s0
	syscall
#size is colorBits(24) bits per pixel, each channel has 3 colors 8 bit BGR. File size is size - offset
#
	#clear histogram buffers
	la $a0, hR
	li $a1, 256
	jal clrBuf
	la $a0, hG
	jal clrBuf
	la $a0, hB
	jal clrBuf
	#iterate over image pixels#
##############################################################
#histogram loop registers:
# t0 - current image memory adress
# t1 - r chan hist mem address
# t2 - g chan mem address
# t3 - g chan mem address
# t4 - current pixel r
# t5 - current pixel g
# t6 - current pixel b
# t7 - pixels left
# t8 - tmp for hist val
# t9 -tmp for address
##############################################################

	lw $t0, soffset
	addu $t0, $t0, $s4 # start address of pixel array
	la $t1, hR
	la $t2, hG
	la $t3, hB
	mulu $t7, $s2, $s3
	#create histograms loop:
histloop:
	lbu $t4, 2($t0)
	lbu $t5, 1($t0)
	lbu $t6, 0($t0)
	addiu $t0, $t0, 3
	#load and increment proper histogram word
	#R
	li $t9, 4
	mulu $t9, $t9, $t4
	addu $t9, $t1, $t9
	lw $t8, 0($t9)
	addiu $t8, $t8, 1
	sw $t8, 0 ($t9)
	#G
	li $t9, 4
	mulu $t9, $t9, $t5
	addu $t9, $t2, $t9
	lw $t8, 0($t9)
	addiu $t8, $t8, 1
	sw $t8, 0 ($t9)
	#B
	li $t9, 4
	mulu $t9, $t9, $t6
	addu $t9, $t3, $t9
	lw $t8, 0($t9)
	addiu $t8, $t8, 1
	sw $t8, 0 ($t9)	
	
	addi $t7, $t7, -1
	bgtz $t7, histloop
	#calculate cumulative sum
###############################################
#REGISTERS
# t1 - address R (all preloaded, will be incremented)
# t2 - address G
# t3 - address B
# t4 - cum R
# t5 - cum G
# t6 - cum B
# t7 - fields left
# t8 - temporary
# a0 - pixel count
# a1 - minimum value R
# a2 - minimum value G
# a3 - minimum value B
###############################################
	li $t7, 256
	li $t4, 0
	li $t5, 0
	li $t6, 0
#store minimum values for histogram channels
	lw $a1, 0($t1)
	lw $a2, 0($t2)
	lw $a3, 0($t3)
	mul $a0, $s2, $s3 # pixel count
	addi $a0, $a0, -1
cumloop:
	#R
	lw $t0, 0($t1) #load histogram value
	addu $t4, $t4, $t0 # add to cumulative sum
	#LUT calculation 
	move $t8, $t4
	sub $t8, $t8, $a1
	mul $t8, $t8, 255
	div $t8, $t8, $a0
	sw $t8, 0($t1) #save in histogram place (LUT)
	#G
	lw $t0, 0($t2) #load histogram value
	addu $t5, $t5, $t0 # add to cumulative sum
	#LUT calculation 
	move $t8, $t5
	sub $t8, $t8, $a1
	mul $t8, $t8, 255
	div $t8, $t8, $a0
	sw $t8, 0($t2) 
	#B
	lw $t0, 0($t3) #load histogram value
	addu $t6, $t6, $t0 # add to cumulative sum
	#LUT calculation 
	move $t8, $t6
	sub $t8, $t8, $a1
	mul $t8, $t8, 255
	div $t8, $t8, $a0
	sw $t8, 0($t3) #save as cumulative sum in histogram place (LUT)
	
	addi $t1, $t1, 4
	addi $t2, $t2, 4
	addi $t3, $t3, 4
	addi $t7, $t7,-1
	bgtz $t7, cumloop
	
#transform image
##############################################################
#transform loop registers:
# t0 - current image memory adress
# t1 - r chan LUT mem address
# t2 - g chan LUT mem address
# t3 - g chan LUT mem address
# t4 - current pixel r
# t5 - current pixel g
# t6 - current pixel b
# t7 - pixels left
# t8 - temporary
# t9 -tmp for address
##############################################################
	lw $t0, soffset
	addu $t0, $t0, $s4 # start address of pixel array
	la $t1, hR
	la $t2, hG
	la $t3, hB
	mul $t7, $s2, $s3 # pixel count
transloop:
	#load pixel value
	lbu $t4, 2($t0)
	lbu $t5, 1($t0)
	lbu $t6, 0($t0)
	#search for lut entry
	mul $t9, $t4, 4 # proper offset for intensity value
	addu $t9, $t9, $t1 #address for channel R
	lw $t4, 0($t9) #load new value
	
	mul $t9, $t5, 4 # proper offset for intensity value
	addu $t9, $t9, $t2 #address for channel G
	lw $t5, 0($t9) #load new value
	
	mul $t9, $t6, 4 # proper offset for intensity value
	addu $t9, $t9, $t3 #address for channel B
	lw $t6, 0($t9) #load new value
	#store new values
	sb $t4, 2($t0)
	sb $t5, 1($t0)
	sb $t6, 0($t0)
	addiu $t0, $t0, 3
	addi $t7, $t7,-1
	bgtz $t7, transloop
	#write output image
		#open file
	li $v0, 13 #call file open
	la $a0, output_file #input file name
	li $a1, 1 # open in writemode
	li $a2, 0 #no special mode
	syscall	
	move $s0, $v0
	
	#read file into memory buffer
	move $a0, $s0
	move $a1, $s4
	li $v0, 15
	move $a2, $s1
	syscall # dump buffer to file
	#close the file
	li $v0, 16
	move $a0, $s0
	syscall
	
exit:
	li $a0, 0
	li $v0, 17
	syscall
	
clrBuf:
	#a0 - buffAddr
	#a1 - size of buffers
	move $t0, $a0 
	move $t1, $a1
cbloop:
	sw $0, 0($t0)
	addi $t0, $t0, 4
	addi $t1, $t1, -1
	bgtz $t1, cbloop
	jr $ra
