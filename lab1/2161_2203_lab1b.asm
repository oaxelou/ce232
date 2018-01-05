# AXELOU OLYMPIA 2161 - TSITSOPOULOU ANASTASIA EIRINI 2203
#
# Implementation of the Binary Search algorithm.
#
# # # # # # # # # # #
# Reigsters used:
#	$s0 : Size of array
#	$s1 : start
#	$s2 : end
#	$s3 : middle
#	$s4 : the value of the middle element of the array
#	$t0 : Temporary register
# # # # # # # # # # # 	

.data

	StringForSize : .asciiz "Enter size of array: "
	StringNl: .asciiz "\n"
	StringError : .asciiz "Error. The size of the array must not be greater than 100."
	StringForSearch : .asciiz "Enter a number to search for: "
	
.align 2
	Array: .space 400

.text
.globl main

main:

Read:
	li $v0, 4
	la $a0, StringForSize
	syscall

	li $v0, 5 # read size of array
	syscall
	
	ble $v0, 100, Continue
	
	li $v0, 4
	la $a0, StringError
	syscall
	
	la $a0, StringNl
	syscall

	j Read

Continue:	
	move $s0, $v0
	li $t0, 0 # init the counter for the loop

ReadLoop:
	li $v0, 5 # reads the ($t0)th integer
	syscall

	sll $t1, $t0, 2 # set offset
	sw $v0, Array($t1) # store integer in certain position in the array

	addi $t0, $t0, 1
	bne $t0, $s0, ReadLoop

	# ***** binary search *****
	li $v0, 4
	la $a0, StringForSearch
	syscall 
	
	li $v0, 5 # get number to search
	syscall

	li $s1, 0  # start 
	sub $s2, $s0, 1 # end

SearchLoop:
	add $s3, $s1, $s2
	srl $s3, $s3, 1  # middle

	sll $t0, $s3, 2 # set offset
	lw $s4, Array($t0)

	bgt $s1, $s2, NotFound  # if(start > end)
	beq $v0,$s4, Found      # if(integer_to_find == array[middle])
	bgt $v0,$s4,  Higher    # if(integer_to_find > array[middle])
	blt $v0,$s4, Lower      # if(integer_to_find < array[middle] )

Lower:
	addi $s2, $s3, -1
	j SearchLoop

Higher:
	addi $s1, $s3, 1
	j SearchLoop

Found:
	li $v0, 1
	move $a0, $s3
	syscall
	j Exit

NotFound:
	li $v0, 1
	li $a0, -1
	syscall

Exit:
	li $v0, 10
	syscall
