# AXELOU OLYMPIA 2161 - TSITSOPOULOU EIRINI 2203
#
# Roman to Decimal Converter
# 
# 1) checks if the string given consists only of roman numerals
# 2) converts number to decimal
#
# # # # # # # # # # # # # # # # # # # # # # # # # # 

.include "macros.h"				# contains read and print macros

.macro CharToInt(%RomanChar)			# converts %RomanChar to its decimal value

	beq %RomanChar, 'M', M1
	beq %RomanChar, 'D', D1
	beq %RomanChar, 'C', C1
	beq %RomanChar, 'L', L1
	beq %RomanChar, 'X', X1
	beq %RomanChar, 'V', V1
	
	addi %RomanChar, $zero, 1
	j EndOfSwitch
V1:	
	addi %RomanChar, $zero, 5
	j EndOfSwitch
X1:
	addi %RomanChar, $zero, 10
	j EndOfSwitch
L1:
	addi %RomanChar, $zero, 50
	j EndOfSwitch
C1:
	addi %RomanChar, $zero, 100
	j EndOfSwitch
D1:
	addi %RomanChar, $zero, 500
	j EndOfSwitch
M1:
	addi %RomanChar, $zero, 1000
	j EndOfSwitch
EndOfSwitch:
.end_macro

.data
	RomanNumber: .space 100

.text
.globl main


main:

Read:	
	PrintString("Please give roman number: ")
	ReadString(RomanNumber)				#string is located in $a0

	jal IsRoman
	 
	beq $v0, 1, ConvertToDecimal
	
	PrintString("Error: Not a roman number\n")
	j Read
	
ConvertToDecimal:
	#convert to decimal
	la $a0, RomanNumber
	jal RomanToDecimal
	PrintNumber($v0)
	
	exit()
	
# # # # # # # # # IsRoman # # # # # # # # # # # #
IsRoman:
	
	lb $t0, ($a0)
	beqz $t0, ReturnTrue		# conditions to stop
	beq $t0, '\n', ReturnTrue
	
	#check if char is roman numeral
	beq $t0, 'M', CheckNextRec
	beq $t0, 'D', CheckNextRec
	beq $t0, 'C', CheckNextRec
	beq $t0, 'L', CheckNextRec
	beq $t0, 'X', CheckNextRec
	beq $t0, 'V', CheckNextRec
	beq $t0, 'I', CheckNextRec
	
	# if char is not roman numeral
ReturnFalse:
	li $v0, 0
	jr $ra
	
CheckNextRec:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	add $a0, $a0, 1		# move one place in string
	jal IsRoman
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	beqz $v0, ReturnFalse
	
ReturnTrue:
	li $v0, 1
	jr $ra

# # # # # # Roman To Decimal # # # # # #

RomanToDecimal:

	lb $t0, ($a0)
	beqz $t0, EndOfRoman		#conditions to stop
	beq $t0, '\n', EndOfRoman
	
	CharToInt($t0)			#converts $t0 to its decimal value
	
	lb $t1, 1($a0)
	beqz $t1, LastRomanChar
	beq $t1, '\n', LastRomanChar 
	
	CharToInt($t1)
	
#  #  #  #  #  #  #  #  #  #  #  #  
	addi $sp, $sp, -12
	sw $ra, ($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	
	addi $a0, $a0, 1
	jal RomanToDecimal
	
	lw $ra, ($sp)
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	addi $sp, $sp, 12
#  #  #  #  #  #  #  #  #  #  #  #  
	
	blt $t0, $t1, Subtract		#check if next byte has larger value than current - subtract it
	add $v0, $v0, $t0
	j Return
	
Subtract:
	sub $v0, $v0, $t0
	j Return
EndOfRoman:
	move $v0, $zero
	j Return

LastRomanChar:
	move $v0, $t0
	j Return 

Return:
	jr $ra
