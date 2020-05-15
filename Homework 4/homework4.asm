		.data
inputFileName:	.asciiz	"input.txt"	
		.align 2
beforeSort:	.ascii "The array before:	"
		.align 	2
afterSort:	.ascii "The array after:		"
		.align 	2
meanMsg:		.ascii "The mean is:	"
		.align 	2
medianMsg:	.ascii "The median is:	"
		.align 	2
stdDevMsg:	.ascii "The standard deviation is:	"
		.align 	2
fileErrorMsg:	.asciiz "The program encountered an error while reading the file."
		.align 	2
endl:		.asciiz "\n"
		.align 	2
bytesRead:	.word	-1
bufLen:		.word 	80
mean:		.float 	0.0
array:		.word 	0:20
buffer:		.asciiz	"This is a buffer"
		.align 	2
read:		.space	80

		.text
main:		
		jal	readFile			# calling function to read input from file
		blez 	$v0, fileError		# if $v0 (bytes read) <= 0, then output error, and exit program.

		la	$a0, array		# passing in address of array
		li	$a1, 20			# passing in length of array
		la	$a2, read		# passing in buffer address
		jal	extract			# function call to extract numbers into array
		
		li	$v0, 4			# printing "The array before:	"
		la	$a0, beforeSort
		syscall
		
		la	$a0, array		# passing in address of array
		li	$a1, 20			# passing in length of array
		jal 	print			# function call to print array
		
		li	$v0, 4			# printing a new line
		la	$a0, endl
		syscall
		
		la	$a0, array		# a0 = base address of array
		li	$a1, 20			# a1 = array size
		jal 	sort			# function call to sort the array
		
		li	$v0, 4			# printing "The array after:	 "
		la	$a0, afterSort
		syscall
		
		la	$a0, array		# printing the array
		li	$a1, 20			# 20 is the length of the array
		jal 	print
		
		li	$v0, 4			# printing a new line
		la	$a0, endl
		syscall
		
		li	$v0, 4			# printing the "The mean is:	"
		la	$a0, meanMsg
		syscall
		
		la	$a0, array		# a0 = array address
		li	$a1, 20			# a1 = array size
		jal 	meanFunc			# calling the mean function to compute mean
		
		li	$v0, 2			# printing the mean (Stored in $f12)
		syscall
		
		li	$v0, 4			# printing a new line
		la	$a0, endl
		syscall
		
		li	$v0, 4			# printing the "The median is:	"
		la	$a0, medianMsg
		syscall
		
		la	$a0, array		# a0 = array address
		li	$a1, 20			# a1 = array size
		jal 	medianFunc		# calling the median function
		move	$t0, $v0
		beq	$v1, 1, printInt
		
		li	$v0, 2			# printing the median as a float
		syscall
		j 	skipPrintInt

printInt:	li	$v0, 1			# printing the median as an int
		move	$a0, $t0
		syscall
		
skipPrintInt:	li	$v0, 4			# printing a new line
		la	$a0, endl
		syscall
		
		li	$v0, 4			# printing the standard deviation message
		la	$a0, stdDevMsg	
		syscall
		
		la	$a0, array		# a0 = array address
		li	$a1, 20			# a1 = array size
		jal 	stdDevFunc		# calling the standard deviation function
		
		li	$v0, 2			# printing the standard deviation
		syscall
		
exit:		li 	$v0, 10			# exits the program
		syscall
		
fileError:	li 	$v0, 4			# outputs an error saying file could not be read
		la	$a0, fileErrorMsg
		syscall
		j 	exit
##################################### READ FILE ###################################################
readFile:	
  		li   	$v0, 13       		# system call for open file
  		la   	$a0, inputFileName    	# input file name
  		li   	$a1, 0        		# 0 flag means it is for reading
 		li   	$a2, 0        		# mode is ignored
 		syscall            		
 		move 	$s6, $v0      		# save the file descriptor (in $v0) 


  		li   	$v0, 14       		# system call for file read
  		move 	$a0, $s6      		# file descriptor 
  		la   	$a1, read     		# address of buffer to read into
  		la  	$a2, bufLen      	# hardcoded buffer length - 80
  		syscall        
  			  
		jr	$ra

##################################### EXTRACT NUMBERS ##############################################
extract:	
#		la	$t1, $a1			# length of array
#		li 	$t3, 48			# 48 is ASCII for 0
#		li	$t4, 57			# 67
		li	$t6, 10
		li 	$t1, 0
		li	$t7, 0
		    		
extLoop:	
		lb	$t2, 0($a2)		# load buffer byte, $t2 = a2[i]
		lb	$t0, 0($a0)		# load array word, $t0 = array[i]
		beq	$t2, 10, incrArray	# new line character indicates end of integer
		beqz	$t2, return		# t2 (buffer byte) == 0
		blt	$t2, 48, jumpExtLoop	# byte < 48, ASCII 48 = '0'
		bgt	$t2, 57, jumpExtLoop	# byte > 57, ASCII 57 = '9'
    		addi	$t2, $t2, -48		# t2 = t2 - 48

    		mul	$t7, $t7, $t6		# t7 = t7 * t6 = t7 * 10
    		add 	$t7, $t2, $t7

jumpExtLoop:   	addi	$a2, $a2, 1		# increment the buffer address
		addi	$t1, $t1, 1		# increment loop counter variable
		j	extLoop
		
incrArray:	sw	$t7, ($a0)		# arr[i] = $t7
		addi	$a0, $a0, 4		# increment the array index
		addi	$a2, $a2, 1
		li	$t7, 0
		j 	extLoop

return:
    		jr      	$ra         # return

####################################### PRINT ######################################################
print:	
		li	$t0, 0		# i = 0
		addi	$t1, $a0, 0 	# pointer to words
		
loop:		beq	$t0, $a1, done	# i == length

		li	$v0, 1		# printing the integer arr[i]
		lw	$a0, ($t1)	# a0 = arr[i]
		syscall
		
		li	$v0, 11		# print a character
		li	$a0, 0x20	# character is a space
		syscall
		
		addi	$t1, $t1, 4	# array address * 4
		addi	$t0, $t0, 1	# i++
		j	loop
		
done:		jr	$ra

###################################### SWAP #########################################################
swap:		
		sll	$t1, $a1, 2		# i * 4
		add	$t1, $a0, $t1		# calculating address of first value
		
		sll	$t2, $a2, 2		# j * 4
		add	$t2, $a0, $t2		# calculating address of second value

		lw	$t0, 0($t1)		# arr[i]
		lw	$t3, 0($t2)		# arr[j]

		sw	$t3, 0($t1)		# arr[i] = arr[j]
		sw	$t0, 0($t2)		# arr[j] = arr[i]

		jr	$ra
		
####################################### SORT #######################################################
sort:
		addi	$sp, $sp, -16	# saving values on stack
		sw	$ra, 0($sp)	# push PC value to stack as another function call will be made
		sw	$s0, 4($sp)	# keep track of base address
		sw	$s1, 8($sp)	# keep track of i
		sw	$s2, 12($sp)	# keep track of array length, n
		
		move	$s0, $a0		# s0 = base address of array
		move	$s1, $a1		# s2 = n
		li	$s2, 0		# i = 0
		
fLoop:
		beq	$s2, $s1, sortRet	# if i == n, exit the first loop
		
		move	$a0, $s0		# a0 = base address 
		move	$a1, $s2		# a1 = i
		move	$a2, $s1		# a2 = n
		jal	findMin		# calling function to find minimum
		
		move	$t0, $v0		# return value of the findMin function
		
		move	$a0, $s0		# a0 = base address of array
		move	$a1, $s2		# a1 = i
		move	$a2, $t0		# a2 = minimum value
		jal swap			# calling function to swap arr[i] and minimum value
		
		addi	$s2, $s2, 1	# i++
		j	fLoop	
		
sortRet:	
		lw	$ra, 0($sp)	# restore values from stack
		lw	$s0, 4($sp)
		lw	$s1, 8($sp)
		lw	$s2, 12($sp)
		#lw	$s3, 16($sp)
		addi	$sp, $sp, 16	# restore stack pointer
		jr	$ra		

############################# FIND MINIMUM #########################################################
findMin:
		move	$t1, $a1		# first index = i
		
		sll	$t2, $t1, 2	# first index * 4
		add	$t2, $t2, $a0	# index = base array address + minimum * 4
		lw	$t3, 0($t2)	# minimum = arr[i]
		
		addi	$t4, $t1, 1	# i = 0

sLoop:		
		beq	$t4, $a2, findMinRet	# if end of array reached, end loop
		
		sll	$t5, $t4, 2	# i * 4
		add	$t5, $t5, $a0	# index = base array address + i * 4
		lw	$t6, 0($t5)	# t7 = arr[i]
		
		bge	$t6, $t3, continue	# if t7 >= minimum, then loop again

		move	$t1, $t4		# minimum = i
		move	$t3, $t6		# minimum = v[i]
		
continue:	addi	$t4, $t4, 1	# i++
		j	sLoop

findMinRet:	move	$v0, $t1		# v0 = minimum
		jr $ra
		
######################################### MEAN #####################################################
meanFunc:		
		li	$t0, 0		# i = 0
		li	$t1, 0		# sum = 0
		
		
sumLoop:		beq	$t0, $a1, exitMean	# exit if i = length
		lw	$t2, ($a0)		# t2 = arr[i]
		add	$t1, $t1, $t2		# sum += array[i]
		addi	$a0, $a0, 4
		addi	$t0, $t0, 1
		j 	sumLoop
		
exitMean:
		mtc1	$t1, $f0		# converting sum from int to float
		cvt.s.w	$f0, $f0		# f0 = sum
		
		move	$t2, $a1		# t2 = array size		
		mtc1	$t2, $f1		# converting length of array from int to float	
		cvt.s.w	$f1, $f1		# f1 = array size

		
		div.s	$f12, $f0, $f1	# average = sum / array size. stored in f12
		swc1	$f12, mean	# saving mean: mean = f12
		
		jr	$ra


################################################## MEDIAN ##########################################
medianFunc:
		li	$t0, 2		# used to find if size is even or odd
		div	$a1, $t0		# array size / 2
		mfhi	$t1		# store the remainder of result
		beqz	$t1, even	# if array size is even, go to even
		j odd			# array size is odd so go to odd

even:
		div	$t2, $a1, 2	# t2 = n/2
		addi	$t3, $t2, -1	# t3 = (n/2) + 1
		
		move	$t4, $t2		# t4 = t2 = i
		sll	$t4, $t4, 2	# t4 = 4 * i
		add	$t5, $a0, $t4	# offset address from arr[0] to arr[i]
		
		lw	$t6, 0($t5)	# t6 = arr[t2]
		mtc1	$t6, $f0		# converting from int to float
		cvt.s.w	$f0, $f0		# f0 = arr[t2]
		
		move	$t4, $t3		# t4 = t2 = i
		sll	$t4, $t4, 2	# t4 = 4 * i
		add	$t5, $a0, $t4	# offset address from arr[0] to arr[i]
		
		lw	$t6, 0($t5)	# t6 = arr[t3]
		mtc1	$t6, $f1		# converting from int to float
		cvt.s.w	$f1, $f1		# f1 = arr[t3]
		
		add.s	$f0, $f0, $f1	# f0 = f0 + f1 : f0 = arr[t2] + arr[t3]
		
		mtc1	$t0, $f2		# convert from int to float
		cvt.s.w	$f2, $f2		# f4 = 2
		
		div.s	$f12, $f0, $f2	# f12 = f0 / f2 : f12 = (arr[t2] + arr[t3]) / 2
		li	$v1, 0		# if v1 == 0, then the number is a float
		jr 	$ra
odd:
		div	$t2, $a1, 2	# t2 = n/2		
		move	$t3, $t2		# t4 = t2 = i
		sll	$t3, $t3, 2	# t4 = 4 * i
		add	$t4, $a0, $t3	# offset address from arr[0] to arr[i]	
		lw	$v0, 0($t4)	# v0 = arr[n/2]
		li	$v1, 1		# if v1 == 1, then the number is an int
		jr $ra
		
		
############################################### STANDARD DEVIATION #################################
stdDevFunc:
		li	$t0, 0		# i = 0
		lwc1	$f0, mean	# f0 = r_avg
		
		mtc1	$t0, $f1		# converting from int to float
		cvt.s.w	$f1, $f1		# used to keep track of sum of (r_i - r_avg)^2, initial sum is 0

stdLoop:		bge	$t0, $a1, exitStd	# if i > array length, exit loop

		lw	$t2, 0($a0)	# t2 = arr[i]		
		mtc1	$t2, $f3		# converting from int to float
		cvt.s.w	$f3, $f3		# f3 = arr[i]
		
		sub.s	$f3, $f3, $f0	# f3 = f3 - f0 : f3 = (r_i - r_avg)
		mul.s	$f3, $f3, $f3	# f3 = f3 * f3 : f3 = (r_i - r_avg)^2
		add.s	$f1, $f1, $f3	# f1 = f1 + f3 : f1 = (r_1 - r_avg)^2 + (r_2 - r_avg)^2 + ... + (r_i - r_avg)^2
		
		addi	$a0, $a0, 4	# next array value
		addi	$t0, $t0, 1	# i++
		
		j	stdLoop

exitStd:
		move	$t2, $a1		# t2 = n
		addi	$t2, $t2, -1	# t2 = n - 1
		mtc1	$t2, $f4		# converting length of array from int to float
		cvt.s.w	$f4, $f4		# f4 = n - 1
		
		div.s	$f0, $f1, $f4	# [(r_1 - r_avg)^2 + (r_2 - r_avg)^2 + ... + (r_i - r_avg)^2) / (n -1)
		sqrt.s	$f12, $f0	# square root of ([(r_1 - r_avg)^2 + (r_2 - r_avg)^2 + ... + (r_i - r_avg)^2) / (n -1))

		jr 	$ra
		
		






