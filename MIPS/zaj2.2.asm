.data
strbuf: .space 256
outbuf: .space 256
charbuf: .byte 32
.text

main:
	#syscall v0=8  a0 input buffer, a1 - max no of chars 
	LI $v0 8
	LA $a0 strbuf
	LI $a1 255
	syscall
	
	LA $t0 charbuf
	LI $t1 24
	
	#initialize memory values to zero 
memloop:
	SB $0 0($t0)
	ADDI $t1 $t1 -1
	ADDI $t0 $t0 1
	BLTZ $t1 memend
	J memloop
memend:
	#loop over string length
	# t1 - inbuf # t4 outbuf #t3 input val
	LA $t1 strbuf
	LA $t4 outbuf
loop:
	LB $t3 0($t1)
	BEQ $t3 $0 loopend
	#check if in letter range
	SB $t3 0($t4)#save letter in the buffer
	ADDI $t4 $t4 1
	
	BGT $t3 'z' loopskip
	BGT $t3 'a' looppass
	BLT $t3 'A' loopskip
	BLT $t3 'Z' loopskip
looppass:
	#increment appropriate buffer value
	LA $t0 charbuf
	ANDI $t2 $t3 0x1F
	ADDI $t2 $t2 -1
	#new address
	ADD $t0 $t0 $t2
	#increment this value and save it
	LB $t5 0($t0)
	ADDI $t5 $t5 1
	SB $t5 0($t0)
	ORI $t5 $t5 0x30 #create ascii number
	#store repeat value
	SB $t5 0($t4)
	ADDI $t4 $t4 1
loopskip:
	ADDI $t1 $t1 1
	J loop
loopend:
	#terminate output string
	ADDI $t4 $t4 1
	SB $0 0($t4)
	LA $a0 outbuf
	LI $v0 4
	syscall
	