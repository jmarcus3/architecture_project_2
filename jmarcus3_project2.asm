.data  
amatrix: .asciiz "C:\Users\marcu\Documents\UChicago\Architecture\project2\architecture_project_2\A.in"
bmatrix: .asciiz "C:\Users\marcu\Documents\UChicago\Architecture\project2\architecture_project_2\B.in"
astart: .align 2
bstart: .align 2
size: .word 64
.text

#########################################################################

dot: # a0 = &A, a1 = &B, a2 = aStride, a3 = bStride, sp = length
	lw 	$t0, 0($sp)			# t0 = length
	addi $sp, $sp, 4 		# popping stack
	li $t1, 0 				# t1 = i
	li $t5, 0				# t5 = sum
dotloop:
	lw $t2, 0($a0)			# t2 = A[i]
	lw $t3, 0($a1)			# t3 = B[i]
	mul $t4, $t3, $t2		# t4 = t2*t3
	add $t5, $t5, $t4		# sum += t4
	addi $t1, $t1, 1		# i++
	add $a0, $a0, $a2		# &A += aStride
	add $a1, $a1, $a3		# &B += bStride
	blt $t1, $t0, dotloop	# loop back if i < length

	addi $v0, $t5, 0		# v0 = sum
	jr $ra 					# return to caller

main:
	# Open matrix A file for reading

	li   	$v0, 13       	# system call for open file
	la   	$a0, amatrix	# input file name
	li   	$a1, 0        	# flag for reading
	li   	$a2, 0        	# mode is ignored
	syscall            		# open a file 
	move 	$s0, $v0      	# save the file descriptor 

	# reading from matrix A

	li   	$v0, 14       	# system call for reading from file
	move 	$a0, $s0      	# file descriptor 
	la   	$a1, astart   	# address of beginning of amatrix
	la 		$t1, size		# address of size variable into t1
	lw		$t2, 0($t1)		# load size into t2 	 
	sll 	$a2, $t2, 2		# multiply inputted size by 4
	syscall            		# read from file

	# storing A matrix on stack, storing A address into S1

	sub $sp, $sp, $a2		# allocate stack memory for matrix A
	move $s1, $sp			# stack address of A on s1
	la  $t0, astart     	# file address of A
	move $t5, $s1 			# A matrix stack pointer 
	li $t4, 0				# t4 = loop counter
aloop:	
	lw $t6, 0($t0)			# load int from A file into t6
	sw $t6, 0($t5)			# store int onto stack
	addi $t0, $t0, 4		# increment A file pointer
	addi $t4, $t4, 1		# increment loop counter
	addi $t5, $t5, 4		# increment A matrix stack pointer
	slt $t3, $t4, $t2		# t3 = 0 if t0 < size
	bne $t3, $0, aloop				 

	# close matrixA

	li		$v0, 16			# system call for closing file
	syscall					# close

	# Open matrix B file for reading

	li   	$v0, 13       	# system call for open file
	la   	$a0, bmatrix	# input file name
	li   	$a1, 0        	# flag for reading
	li   	$a2, 0        	# mode is ignored
	syscall            		# open a file 
	move 	$s0, $v0      	# save the file descriptor 

	# reading from matrix B

	li   	$v0, 14       	# system call for reading from file
	move 	$a0, $s0      	# file descriptor 
	la   	$a1, bstart   	# address of beginning of amatrix	 
	sll 	$a2, $t2, 2		# multiply inputted size by 4
	syscall            		# read from file

	# storing B matrix on stack, storing B address into S2

	sub $sp, $sp, $a2		# allocate stack memory for matrix A
	move $s2, $sp			# stack address of A on s2
	la  $t0, bstart     	# file address of A
	move $t5, $s2 			# A matrix stack pointer 
	li $t4, 0				# t4 = loop counter
bloop:	
	lw $t6, 0($t0)			# load int from B file into t6
	sw $t6, 0($t5)			# store int onto stack
	addi $t0, $t0, 4		# increment B file pointer
	addi $t4, $t4, 1		# increment loop counter
	addi $t5, $t5, 4		# increment B matrix stack pointer
	slt $t3, $t4, $t2		# t3 = 0 if t0 < size
	bne $t3, $0, bloop				 

	# close matrix B

	li	$v0, 16			#system call for closing file
	syscall					#close

#test dot product
	addi $a0, $s1, 0
	addi $a1, $s2, 0
	addi $a2, $0, 4
	addi $a3, $0, 32
	addi $t7, $0, 8
	addi $sp, $sp, -4
	sw $t7, 0($sp)
	jal dot

	addi $a0, $v0, 0
	addi $v0, $0, 1
	syscall

	li $v0, 10
	syscall

