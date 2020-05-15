# Author: Humza Salman
# Class: CS 3340.502
# Homework 2

.data
a:		.word 1
b:		.word 1
c:		.word 1
output1:		.word 6
output2:		.word 6
output3:		.word 6
userName:	.asciiz "tempName"
namePrompt:	.asciiz "Please enter your name: "
integerPrompt:	.asciiz "Please enter an integer between 1-100: "
resultPrompt:	.asciiz "Your answers are: "
	
.text
main:
	# prompt user for name
	li	$v0, 4	# "4"-service code to print strings
	la	$a0, namePrompt
	syscall		# syscall serves as a semi-colon
	
	# get name from user and save it
	li	$v0, 8	# "8"-service code to read strings
	la	$a0, userName	# userName stores the name
	li	$a1, 20	#"20"-represents maximum number of characters to read
	syscall
	
	# prompt user for first integer
	li	$v0, 4
	la	$a0, integerPrompt
	syscall
	
	# get first integer from user and store it
	li	$v0, 5	# "5"-service code for reading integers
	syscall
	sw	$v0, a
	
	# prompt user for second integer
	li	$v0, 4
	la	$a0, integerPrompt
	syscall
	
	# get second integer from user and store it
	li	$v0, 5	# "5"-service code for reading integers
	syscall
	sw	$v0, b
	
	# prompt user for third integer
	li	$v0, 4
	la	$a0, integerPrompt
	syscall
	
	# get third integer from user and store it
	li	$v0, 5	# "5"-service code for reading integers
	syscall
	sw	$v0, c
	
	# loading integers into saved registers
	lw	$s1, a
	lw	$s2, b
	lw	$s3, c
	
	# calculating output 1: 2a - b + 9
	add	$t1, $s1, $s1	# 2a = a + a
	sub	$t2, $t1, $s2	# 2a - b
	addi	$t2, $t2, 9	# (2a - b) + 9
	sw	$t2, output1	# storing result into output 1
	
	# calculating output 2: c - b + (a - 5)
	sub	$t1, $s3, $s2	# c - b
	subi	$t2, $s1, 5	# (a - 5)
	add	$t1, $t1, $t2	# (c - b) + (a - 5)
	sw	$t1, output2	# storing result into output 2
	
	# calculating output 3: (a - 3) + (b + 4) - (c + 7)
	subi	$t1, $s1, 3	# (a - 3)
	addi	$t2, $s2, 4	# (b + 4)
	addi	$t3, $s3, 7	# (c + 7)
	add	$t1, $t1, $t2	# (a - 3) + (b + 4)
	sub	$t1, $t1, $t3	# [(a - 3) + (b + 4)] - (c + 7)
	sw	$t1, output3	# storing result into output 1
	
	# print user's name
	li	$v0, 4
	la	$a0, userName
	syscall
	
	# print result prompt
	li	$v0, 4
	la	$a0, resultPrompt
	syscall
	
	# printing calculated outputs
	li	$v0, 1	# "1"-service code to print integers
	lw	$a0, output1
	syscall
	li	$v0, 11	# "11"-service code for printing a character
	li	$a0, 32 # "32"-ASCII code for space character
	syscall
	li	$v0, 1
	lw	$a0, output2
	syscall
	li	$v0, 11
	li	$a0, 32
	syscall
	li	$v0, 1
	lw	$a0, output3
	syscall
	
	li	$v0, 10 # "10"-service code to exit/terminate
	syscall
	
	# Sample Run #1: 
	# Given: a = 15, b = 5, c = 4
	# Expected: output1 = 34, output2 = 9, output3 = 4
		# Please enter your name: humza
		# Please enter an integer between 1-100: 15
		# Please enter an integer between 1-100: 5
		# Please enter an integer between 1-100: 4
		# humza
		# Your answers are: 34 9 10
		# -- program is finished running --
		
	# Sample Run #2: 
	# Given: a = 2, b = 30, c = 50
	# Expected: output1 = -17, output2 = 17, output3 = -24
		# Please enter your name: humza
		# Please enter an integer between 1-100: 2
		# Please enter an integer between 1-100: 30
		# Please enter an integer between 1-100: 50
		# humza
		# Your answers are: -17 17 -24
		# -- program is finished running --