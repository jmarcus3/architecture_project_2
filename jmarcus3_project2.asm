.data  
amatrix: .asciiz "C:\Users\marcu\Documents\UChicago\Architecture\project2\architecture_project_2\A.in"
bmatrix: .asciiz "C:\Users\marcu\Documents\UChicago\Architecture\project2\architecture_project_2\B.in"
cmatrix: .asciiz "C:\Users\marcu\Documents\UChicago\Architecture\project2\architecture_project_2\C.out"
astart: .align 2
bstart: .align 2
#cstart: .align 2
length: .word 8
.text

#########################################################################

dot: # a0 = &A, a1 = &B, a2 = aStride, a3 = bStride, sp = length
	lw 	$t0, 0($sp)			# t0 = length
	addi $sp, $sp, 4 		# popping stack
	li $t1, 0 				# t1 = i
	li $t5, 0				# t5 = sum
dotloop:
	bge $t1, $t0, exit_dot	# jump to exit if i >= length
	lw $t2, 0($a0)			# t2 = A[i]
	lw $t3, 0($a1)			# t3 = B[i]
	mul $t4, $t3, $t2		# t4 = t2*t3
	add $t5, $t5, $t4		# sum += t4
	addi $t1, $t1, 1		# i++
	add $a0, $a0, $a2		# &A += aStride
	add $a1, $a1, $a3		# &B += bStride	
	j dotloop
exit_dot:
	addi $v0, $t5, 0		# v0 = sum
	jr $ra 					# return to caller

mxm: #a0 = &A, a1 = &B, a2 = &C, a3 = length
	sw $s4, -4($sp)			# push s4 onto stack
	sw $s5, -8($sp)			# push s5 onto stack
	sw $s6, -12($sp)		# push s6 onto stack
	addi $sp, $sp, -12		# allocate space on stack
	li $s4, 0				# s4 = loop1 counter 
	move $s6, $a1			# store B beginning address into s6
mxmloop1:
	bge $s4, $a3, exit_mxm	# branch to exit_mxm if loop1 counter >= length  			
	move $a1, $s6			# restore a1 to first column of B
	li $s5, 0				# s5 = loop2 counter	
mxmloop2:
	bge $s5, $a3, exit_loop1	# branch to exit_loop1 if loop2 counter >= length
	sw $a0 -4($sp)				# store a0 to stack
	sw $a1 -8($sp)				# store a1 to stack
	sw $a2 -12($sp)				# store a2 to stack
	sw $a3 -16($sp)				# store a3 to stack
	sw $ra -20($sp)				# store ra to stack
	addi $sp, $sp, -20			# allocate space on stack
	li $a2, 4					# storing 4 into a2 for dot product aStride
	sw $a3 -4($sp)				# storing length into stack for dot product length
	addi $sp, $sp, -4			# moving stack pointer
	mul $a3, $a3, $a2 			# multiplying length by 4, storing in a3 for dot product bStride
	jal dot 					# calling dot product
	addi $sp, $sp, 20			# restoring stack pointer to proper spot
	lw $ra, -20($sp)			# restoring ra
	lw $a3, -16($sp)			# restoring a3
	lw $a2, -12($sp)			# restoring a2
	lw $a1, -8($sp)				# restoring a1
	lw $a0, -4($sp)				# restoring a0
	sw $v0, 0($a2)				# storing return of dot to matrix C
	addi $a2, $a2, 4			# increment address pointer to matrix C
	addi $s5, $s5, 1			# increment loop2 counter
	addi $a1, $a1, 4			# increment column address for B
	j mxmloop2
exit_loop1:
	addi $s4, $s4, 1		# increment loop1 counter
	sll $t0, $a3, 2			# multiply length by 4 and store into t0 stride length
	add $a0, $a0, $t0		# increment A pointer to next row
	j mxmloop1
exit_mxm:
	addi $sp, $sp, 12 		# restore stack pointer
	lw $s6, -12($sp)		# restore s6
	lw $s5, -8($sp)			# restore s5
	lw $s4, -4($sp)			# restore s4
	jr $ra 					# return to caller


main:
	# Open matrix A file for reading

	li   	$v0, 13       	# system call for open file
	la   	$a0, amatrix	# address of A.in
	li   	$a1, 0        	# flag for reading
	li   	$a2, 0        	# mode is ignored
	syscall            		# open a file 
	move 	$s0, $v0      	# save the file descriptor 

	# reading from matrix A

	li   	$v0, 14       	# system call for reading from file
	move 	$a0, $s0      	# file descriptor 
	la   	$a1, astart   	# address of beginning of amatrix
	la 		$t1, length		# address of length variable into t1
	lw		$s4, 0($t1)		# load length into s4
	mul 	$t2, $s4, $s4	# compute size of square matrix and store in t2	
	sll 	$a2, $t2, 2		# multiply size by 4
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
	la   	$a0, bmatrix	# address of B.in
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
	move $s2, $sp			# stack address of B on s2
	la  $t0, bstart     	# file address of B
	move $t5, $s2 			# A matrix stack pointer 
	li $t4, 0				# t4 = loop counter
bloop:	
	lw $t6, 0($t0)			# load int from B file into t6
	sw $t6, 0($t5)			# store int onto stack
	addi $t0, $t0, 4		# increment B file pointer
	addi $t4, $t4, 1		# increment loop counter
	addi $t5, $t5, 4		# increment B matrix stack pointer
	slt $t3, $t4, $t2		# t3 = 0 if t0 < length
	bne $t3, $0, bloop				 

	# close matrix B

	li	$v0, 16				# system call for closing file
	syscall					# close

	# allocating memory on stack for C matrix:
	
	sub $sp, $sp, $a2 		# allocate stack memory for matrix C
	move $s3, $sp			# save stack address of C onto s3			

	# call to mxm subroutine

	move $a0, $s1 			# store A address into a0 for call to mxm
	move $a1, $s2 			# store B address into a1 for call to mxm
	move $a2, $s3			# store C address into a2 for call to mxm
	move $a3, $s4			# store length into a3 for call to mxm
	jal mxm

	# test output
	
	mul $t0, $s4, $s4		# store size of matrix in t0
	li $t1, 0				# initialize loop counter
	move $t2, $s3			# initialize C pointer to C address

cloop:
	bge $t1, $t0 cloop_exit	# branch to exit if loop counter >= matrix size
	lw $a0, 0($t2)			# load integer from C into a0
	addi $v0, $0, 1			# setup syscall code 1 (print int)
	syscall					# print int
	addi $t2, $t2, 4		# increment C pointer
	addi $t1, $t1, 1		# increment loop counter
	j cloop 				# jump to beginning of loop
cloop_exit:

	# Open matrix C file for writing

	li   	$v0, 13       	# system call for open file
	la   	$a0, cmatrix	# address of c.out
	li   	$a1, 0x4102     # flag for creating and writing
	li   	$a2, 0x80      	# mode that doesn't break
	syscall            		# open a file 

	# add to file

	move $a0, $v0  			# move file descriptor to a0
    li $a2, 4				# set count to length of integer
    move $a1, $s3			# move address of beginning of C matrix to a1
	li $t1, 0				# initialize loop counter
	move $t2, $s3			# initialize C pointer to C address

cloop2:
	bge $t1, $t0 cloop_exit2	# branch to exit if loop counter >= matrix size
	move $a1, $t2				# move C pointer address to a1
    li $v0, 15					# system call for write to file
	syscall						# add int at a3 to file
	addi $t2, $t2, 4			# increment C pointer
	addi $t1, $t1, 1			# increment loop counter
	j cloop2 					# jump to beginning of loop
cloop_exit2:

	li $v0, 16				# system call for closing file
	syscall					# close     

#test dot product
	#addi $a0, $s1, 0
	#addi $a1, $s2, 0
	#addi $a2, $0, 4
	#mul $a3, $s4, $a2
	#addi $sp, $sp, -4
	#sw $s4, 0($sp)
	#jal dot

	#addi $a0, $v0, 0
	#addi $v0, $0, 1
	#syscall

	li $v0, 10
	syscall

