# AXELOU OLYMPIA 2161 - TSITSOPOULOU EIRINI 2203
#
# Implementation of 64-bit Subtraction
#
#	 MSB	 LSB
#	($t0)	($t1)
#     - ($t2)	($t3)
#	______________
#	($t0)	($t1)
#
# # # # # # # # # # # # # # # # # # # # # # # # # # 

.include "macros.h"	# file includes print and read macros

.text
.globl main

main:	
	Get64bitNumber($t0, $t1)
	Get64bitNumber($t2, $t3)
	
	# subtraction
	sub $t0, $t0, $t2		# subtract msb
	bge $t1, $t3, notCarry		# positive or zero result from lsb subtraction
	subi $t0, $t0, 1		# subtract carry

notCarry:	
	subu $t1, $t1, $t3		# subtract lsb

Exit:	
	PrintInHex($t0, $t1)
	
	exit()