.data
strbuf: .space 256
.text

main:
	#syscall v0=8  a0 input buffer, a1 - max no of chars 
	LI $v0 8
	LA $a0 strbuf
	LI $a1 255
	syscall
	#xor value for letter size toggle
	LI $t0 0x20
	#loop over string length
	LA $t1 strbuf
loop:
	LB $t3 0($t1)
	BEQ $t3 $0 loopend
	#check if in letter range
	BGT $t3 'z' loopskip
	BGT $t3 'a' looppass
	BLT $t3 'A' loopskip
	BLT $t3 'Z' looppass
looppass:	
	
	XOR $t3 $t3 $t0
	SB $t3 0($t1)
loopskip:
	ADDI $t1 $t1 1
	J loop
loopend:
	LI $v0 4
	syscall
	