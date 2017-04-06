.data
	input_file: .asciiz "lena.bmp"
	.align 2
	buffer: .space 256
	size: .space 4
	width: .space 4
	height: .space 4
	soffset: .space 4
	hR: .word 256
	hG: .word 256
	hB: .word 256
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
	#read file into memory buffer
	move $a1, $s4
	li $v0, 14
	move $a2, $s1
	syscall # read whole file
	#close the file
	li $v0, 16
	move $a0, $s0
	syscall
	
	
exit:
	li $a0, 0
	li $v0, 16
	syscall
	
clrBuf:
	#a0 - buffAddr
	#a1 - size of buffers
	move $t0, $a0 
	move $t1, $t1
cbloop:
	sw $0, 0($t0)
	addiu $t0, $t0, 4
	addiu $t1, $t1, -4
	bgtz $t1, cbloop
	jr $ra