.data
	input_file: .asciiz "test.txt"
	buffer: .space 256
.text
	#open file
	li $v0, 13 #call file open
	la $a0, input_file #input file name
	li $a1, 0 # open in readmode
	li $a2, 0 #no special mode
	syscall
	move $s0, $v0 #save file descripter
	# read data from file
	move $a0, $s0
	li $v0, 14
	la $a1, buffer
	li $a2, 256
	syscall
	#print read data
	li $v0, 4
	la $a0, buffer
	syscall
	#close the file
	li $v0, 16
	move $a0, $s0
	syscall