.macro PrintString(%string)
	.data
	StringToPrint: .asciiz %string
	
	.text 
	li $v0, 4
	la $a0, StringToPrint 
	syscall
.end_macro

.macro PrintNumber(%number)
	move $a0, %number
	li $v0, 1
	syscall
.end_macro

.macro ReadString(%string)
	li $v0, 8
	la $a0, %string
	li $a1, 100
	syscall
.end_macro

.macro ReadNumber(%number)
	li $v0, 5
	syscall
	move %number, $v0
.end_macro

.macro Get64bitNumber(%msb, %lsb)
	PrintString("Enter 32 msb of number: ")
	ReadNumber(%msb)
	
	PrintString("Enter 32 lsb of number: ")
	ReadNumber(%lsb)
.end_macro 

.macro PrintInHex( %msb, %lsb)
	li $v0, 34 
	move $a0, %msb
	syscall
	
	PrintString(" ")
	
	li $v0, 34 
	move $a0, %lsb
	syscall
.end_macro

.macro exit()
	li $v0, 10
	syscall
.end_macro
