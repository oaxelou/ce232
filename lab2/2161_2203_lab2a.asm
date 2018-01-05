# AXELOU OLYMPIA 2161 - TSITSOPOULOU EIRINI 2203
#
# The program takes a string and a "substring" as arguments
# and searches for the maximum part of substring in string
# Returns maximum length of substring
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

.include "macros.h"	# file includes print and read macros

.data
BasicString: .space 100
SubString:  .space 100

.text
.globl main

main:
	PrintString("Please give string: ")
	ReadString(BasicString, 100)

	PrintString("Please give substring: ")
	ReadString(SubString, 100)

	la $a0, BasicString
	la $a1, SubString

	# Find the max substring
	jal SubStringFunction
	move $t0, $v0

	PrintString("The max substring length : ")
	PrintNumber($t0)
	PrintString("\n")

Exit:
	li $v0, 10
	syscall

# # # # # # # # # # # # # # # # # # # # # # # # # # # #
#          SubStringFunction:
#
# Arguments:
#	$a0: address of BasicString[0]
#	$a1: address of SubString[0]
#
# Registers used for this function:
# 	$s0: byte loaded for BasicString
# 	$s1: byte loaded for SubString
# 	$t1: offset + address of SubString[0]
# 	$t2: counter of max length of substring
#
# Output:
#	$s2: max length of substring in BasicString
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # #

SubStringFunction:

	move $t1, $a1
	move $t2, $zero
	move $s2, $zero

Loop:
	lb  $s0, ($a0)
	lb  $s1, ($t1)

	beqz $s0, Return	# check if we reached the end of the BasicString
	beq $s0, '\n', Return	# check if we reached '\n' in the BasicString
	beqz $s1, Return	# has found the whole substring
	beq $s1, '\n', Return	# check if we reached '\n' in the SubString

	bne $s0, $s1, NotEqual
	addi $t2, $t2, 1
	j EndOfEqualIf

NotEqual:
	sub $a0, $a0, $t2	# go back ($t2) bytes in BasicString (t2: temporary max length of substr)

	move $t2, $zero		# reset counter
	addi $t1, $a1, -1 	# go to substr[0]

EndOfEqualIf:
	bge $s2, $t2, NoMaxChange
	move $s2, $t2			# save new max length of substr

NoMaxChange:
	addi $a0, $a0, 1
	addi $t1, $t1, 1

	j Loop

Return:
	move $v0, $s2
	jr $ra
