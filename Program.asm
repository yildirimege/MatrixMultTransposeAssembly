#####################################################
#### CMP 2008 Computer Organization Term Project ####
####        Ege Yildirim    /     1734536        ####
#####################################################



.data
	message1: .asciiz "First matrix: \n"
	message2: .asciiz "Second matrix: \n"
	message3: .asciiz "Transpose of first matrix: \n"
	message4: .asciiz "Result matrix:  (Transpose of Matrix1 * Matrix2)\n"
	errorMessage: .asciiz "Row Size of Matrix1 must be equal to Row size of Matrix2!"
	
	spaces: .asciiz " "
	nLine: .asciiz "\n"
	
	matrix1: .word 1, 2
		 .word 3, 4
		 .word 5, 6
		
		 
	matrix2: .word 6, 7, 8
		 .word 9, 10, 11
		 .word 1, 2, 3
		 
	transpose: .word 0, 0
		   .word 0, 0
		   .word 0, 0
		 
	rowSize1: .word 3
	colSize1: .word 2
	
	rowSize2: .word 3
	colSize2: .word 3
	
	resultMatrix: .word 0, 0, 0, 0, 0, 0
	
	.eqv dataSize 4					# Data size is used in acces element formula, i set it to 4 as constant value.
	
.text
	lw $s1, rowSize1
	lw $s2, rowSize2
	lw $s3, colSize1
	lw $s4, colSize2
	
	la $a1, matrix1
	la $a2, matrix2
	la $a3, transpose
	la $k0, resultMatrix
	
	li $t1, 0 # i
	li $t2, 0 # j
	li $t9, 0 #k

	main:
		
		
		
		li $v0, 4
		la $a0, message1			
		syscall 
		
		jal printMatrix1
		
		li $v0, 4
		la $a0, message2
		syscall
		
		jal printMatrix2
		
		bne $s1, $s2, printError       # After printing 2 matrixes, print error message if rowSize1 is not equal to rowSize2
		
		li $v0, 4
		la $a0, message3
		syscall
		
		jal transposeFunc
		
		jal printTranspose
		
		jal multiplyMatrix
		
		li $v0, 4
		la $a0, message4
		syscall
		
		jal printResult
		
		li $v0, 10
		syscall
		
#########################################################################################
	printError:
		li $v0, 4
		la $a0, errorMessage			
		syscall
		li $v0,10
		syscall
		
#########################################################################################

	printResult:
		 	bge $t1, $s3, exitPrintResult
		 	
		 	innerLoopPrintRes:
		 		bge $t2, $s4, exitResultInner
		 		
		 		mul $t3, $t1, $s4
		 		add $t3, $t3, $t2
		 		mul $t3, $t3, dataSize
		 		add $t3, $t3, $k0			# t3 has address of C [i] [j]
		 		
		 		lw $t4, ($t3)				# t4 has value of C [i] [j]
		 		
		 		li $v0, 1
		 		move $a0, $t4				# Printing value of C[i] [j]
		 		syscall
		 		
		 		li $v0, 4
		 		la $a0, spaces
		 		syscall
		 		
		 		addi $t2, $t2, 1
		 		j innerLoopPrintRes
		 			
		 			exitResultInner:
		 				li $t2, 0
		 				addi $t1, $t1, 1
		 				
		 				li $v0, 4
		 				la $a0, nLine		# Print new line after printing one row is completed.
		 				syscall
		 				
		 				j printResult
		 				
		 		exitPrintResult:
		 			li $t1, 0
		 			li $t2, 0
		 			jr $ra
		 				
		
#########################################################################################


	multiplyMatrix:              # Result = Transpose * Matrix2
	
			bge $t1, $s3, exitFirstLoop
			
			SecondLoop:
				bge $t2, $s4, exitSecondLoop
			thirdLoop:
				bge $t9, $s2, exitThirdLoop
				
				mul $t3, $t1, $s4
				add $t3, $t3, $t2
				mul $t3, $t3, dataSize
				add $t3, $t3, $k0		# t3 has address of Result [i] [j]
				
				lw $t6, ($t3)			# t6 has value of  Result [i] [j]
				
				
				mul $t4, $t1, $s1
				add $t4, $t4, $t9
				mul $t4, $t4, dataSize
				add $t4, $t4, $a3		# t4 has address of Trans [i] [k]
				
				lw $t7, ($t4)			# t7 has value of Trans [i] [k]
				
				
				mul $t5, $t9,  $s4
				add $t5, $t5, $t2
				mul $t5, $t5, dataSize
				add $t5, $t5, $a2		#t5 has address of Matrix2 [k] [j]
				
				lw $t8, ($t5)			#t8 has value of Matrix2 [k] [j]
				
				mul $s7, $t7, $t8		# s7 = Trans [i] [k]    *    Matrix2 [k] [j]
				
				add $t6, $t6, $s7		# C [i] [j] + Trans [i] [k]    *    Matrix2 [k] [j]
				
				sw $t6, ($t3)			# C [i] [j] += Trans [i] [k]    *    Matrix2 [k] [j]
				
				addi $t9, $t9, 1		# increment the counter, k is third inner loop value and $s2 is mutual row/column ( colsize of transpose = rowSize of matrix1)
				j thirdLoop
				
					exitThirdLoop:
						li $t9,0
						addi $t2, $t2, 1
						j SecondLoop
						
				exitSecondLoop:
					li $t2, 0
					addi $t1, $t1, 1
					j multiplyMatrix
				
				exitFirstLoop:
					li $t1, 0
					li $t2, 0			# reset i and j
					jr $ra
				

#########################################################################################		

	printMatrix1:
	
			bge $t1, $s1, exitPrint1
			
			innerLoop1:
				bge $t2, $s3, exitInnerLoop1
				
				mul $t3, $t1, $s3
				add $t3, $t3, $t2
				mul $t3, $t3, dataSize
				add $t3, $t3, $a1		#t3 has address of Matrix1 [i] [j]
				
				lw $t4, ($t3)
				
				li $v0, 1
				move $a0, $t4
				syscall
				
				li $v0, 4
				la $a0, spaces
				syscall
				
				addi $t2, $t2, 1
				j innerLoop1
				
				exitInnerLoop1:
					li $v0, 4
					la $a0, nLine
					syscall
					
					li $t2, 0
					addi $t1, $t1, 1
					j printMatrix1
					
				exitPrint1:
					li $t1,0
					li $t2, 0
					jr $ra
					
#########################################################################################

	printMatrix2:
			bge $t1, $s2, exitPrint2
			
			innerLoop2:	
				bge $t2,  $s4, exitInner2
				
				mul $t3, $t1,$s4
				add $t3, $t3, $t2
				mul $t3, $t3, dataSize
				add $t3, $t3, $a2
				
				lw $t4, ($t3)
				
				li $v0, 1
				move $a0, $t4
				syscall
				
				li $v0, 4
				la $a0, spaces
				syscall
				
				addi $t2, $t2, 1
				j innerLoop2
				
				exitInner2:
					li $t2, 0
					addi $t1, $t1, 1
					
					li $v0, 4
					la $a0, nLine
					syscall
					
					j printMatrix2
								
				exitPrint2:
					li $t1, 0
					li $t2, 0
					jr $ra			
				
#########################################################################################

	printTranspose:
			
			bge $t1, $s3, exitPrintTranspose
			
			innerPrintTranspose:
				bge $t2, $s1, exitInnerPrintTranspose
				
				mul $t3, $t1, $s1
				add $t3, $t3, $t2
				mul $t3, $t3, dataSize
				add $t3, $t3, $a3 		# t3 has address of trans [i] [j]
				
				lw $t4, ($t3)			
				
				li $v0, 1
				move $a0, $t4
				syscall
				
				li $v0, 4
				la $a0, spaces
				syscall
				
				addi $t2, $t2, 1
				j innerPrintTranspose
				
				exitInnerPrintTranspose:
					li $t2, 0
					addi $t1, $t1, 1
					
					li $v0, 4
					la $a0, nLine
					syscall
					
					j printTranspose
					
				exitPrintTranspose:
					li $t1, 0
					li $t2, 0
					jr $ra
			
			
#########################################################################################

	transposeFunc:
		
			bge $t1, $s1, exitTranspose
			
			innerLoopTrans:
				bge $t2, $s3, exitInnerTrans
				
				mul $t3, $t1, $s3
				add $t3, $t3, $t2
				mul $t3, $t3, dataSize
				add $t3, $t3, $a1		# t3 has address of Matrix1 [i] [j]
				lw $t5, ($t3)
				
				
				mul $t4, $t2, $s1
				add $t4, $t4, $t1
				mul $t4, $t4, dataSize
				add $t4, $t4, $a3		# t4 has address of Trans [j] [i]
				
				
				sw $t5, ($t4)			# Trans [j] [i] = Matrix1 [i] [j]
				
				addi $t2, $t2, 1
				
				j innerLoopTrans
				
				exitInnerTrans:
					li $t2, 0
					addi $t1, $t1, 1
					j transposeFunc
					
				exitTranspose:
					li $t1,0
					li $t2,0
					
					jr $ra
								
