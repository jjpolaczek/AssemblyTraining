.data
	hello:	.asciiz "Hello World!"
	compare: .asciiz "Hello World!"
.text
	ORI $v0, $zero, 4
	LA $a0, hello #load pointers to registers
	LA $a1, compare
	syscall	#print string
	JAL strcmp
	LI $v0,1
	syscall	#execute jump to strcomp
	LI $v0, 10
	syscall	#terminate program
	
strlen:
	MOVE $s2, $a0 #copy start pointer
loopsl:
	LB $t2, 0($s2)
	BEQ $t2, $zero, endsl #jump conditionally 
	ADDIU $s2, $s2, 1#increment memory address
	J loopsl
endsl:
	SUB $a0, $s2, $a0 #calculate offset string length
	JR $ra
	
strcmp:
	MOVE $s2, $a0 #copy start pointer of string 1
	MOVE $s3, $a1 #copy start pointer of string 2
loopsc:
	LB $t2, 0($s2)#load bytes into memory
	LB $t3, 0($s3)
	BEQ $t2, $zero, chkendsc #jump if string end
	BEQ $t3, $zero, chkendsc #jump if string 2 end
	BNE $t2, $t3, endsc #end if strings are different
	ADDIU $s2, $s2, 1#increment memory address of string 1 
	ADDIU $s3, $s3, 1#increment memory address of string 2
	J loopsc
chkendsc:
	BNE $t2, $t3, endsc #Check for end condition
	LI $a0, 0 #success
	JR $ra
endsc:
	
	LI $a0, -1#failed
	JR $ra
