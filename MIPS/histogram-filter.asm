.data
	input_file: .asciiz "lena.bmp"
	.align 2
	buffer: .space 256
	size: .space 4
	width: .space 4
	height: .space 4
	soffset: .space 4
.text
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
	#li $v0, 1
	#lw $a0, 0($a1)
	#syscall #print image size
	
	move $a0, $s0
	la $a1, buffer
	li $v0, 14
	li $a2, 4 #skip first 4 bytes
	syscall
	la $a1, soffset
	li $v0, 14
	li $a2, 4
	syscall #read image start offset
	#li $v0, 1
	#lw $a0, 0($a1)
	#syscall #print image offset
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
	la $a1, height
	li $v0, 14
	li $a2, 4 
	syscall # load height

fclose:
	#close the file
	li $v0, 16
	move $a0, $s0
	syscall
