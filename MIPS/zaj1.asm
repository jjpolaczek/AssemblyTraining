.data

msg1: .asciiz "Podaj 1 liczbe:\r\n"
msg2: .asciiz "Podaj 2 liczbe: \r\n"
msg3: .asciiz "Wynik:"
msg4: .asciiz "\r\n"
.align 4
array: .byte 3,5,7

.text
.globl main
main:
	li $t4, 0
	li $v0, 4
	la $a0, msg1
	syscall
	
	li $v0 , 5
	syscall
	move $t0, $v0
	la $t3, array
	lb $t4, 2($t3)
	add $t2, $t0, $t4
	
	#lh $t3, 1($t3)
	li $v0, 4
	la $a0, msg3
	syscall
	
	li $v0, 1
	move $a0, $t2
	syscall
	
	li $v0, 4
	la $a0, msg4
	syscall
	
	#jr $ra
	li $v0, 10
	syscall
	
	