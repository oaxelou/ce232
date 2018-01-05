.text
.globl main

main:
	add $t2, $t1, $0     #$10 = $9 + $0
	beq $t1, $t2, label  #if($10 == $11)
	sw $t1, 5($t3)       #mem[$11 + 5] = $9 = 9
	lw $s2, 5($t3)       #$18 = mem[$11 + 5] = 9
	slt $t1, $t0, $s3    #$9 = ($8 < $19) ? 1 : 0 = 1
	or $t7, $t7, $t5     #or $15, $15, $13
label:
	add $t4, $t3, $t1	 #add $12, $11, $9