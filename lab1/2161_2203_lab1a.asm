# AXELOU OLYMPIA 2161 - TSITSOPOULOU ANASTASIA EIRINI 2203
#
# This program checks if an integer given by the user is a power of two.
#
# # # # # # # # # # #
# Reigsters used:
#	$s0 : The number given by the user
#	$t0 and $t1 : Temporary registers
# # # # # # # # # # #

.data
	String_number: .asciiz "Number "
	String_false:  .asciiz " is not a power of two"
	String_true:   .asciiz " is a power of two"
	String_nl:     .asciiz "\n"

.text
.globl main

main:
	#read input and store it in $s0
	li $v0, 5
	syscall
	move $s0, $v0

	la $a0, String_number	#print "number"
	li $v0, 4
	syscall

	move $a0, $s0		#print input number
	li $v0, 1
	syscall

	#check if x & x-1 = 0
	#powers of two in binary have 1 in their most significant bit, followed by zeros
	#the previous number is therefore a string of 1's
	#the "and" operation should give 0 if the input is a power of two, since 1's are found in different bits of the numbers

	addi $t1, $s0, -1
	and $t0, $s0, $t1
	beq $t0, $0, true

	la $a0, String_false	#print string for false
	li $v0, 4
	syscall

	j exit

true:				#print string for true
	la $a0, String_true
	li $v0, 4
	syscall

exit:
	la $a0, String_nl	#print new line
	li $v0, 4
	syscall

	li $v0,10		#exit
	syscall
