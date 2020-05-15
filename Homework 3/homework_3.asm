		.data
characters:	.word	0	# store characters here
words:		.word 	0	# store words here
maxLength:	.word 	51 	# maximum characters threshold, including \n

input:		.asciiz ""
		.align 2
		.space 50	# allows 50 bytes of space so that it doesn't take over byte storage for msg, etc.
msg:		.asciiz	"Enter some text:"
		.align 2
printWords:	.ascii " word(s) "
		.align 2
printCharacters:	.ascii " character(s)\n"
		.align 2
goodbye:		.asciiz "exiting program... hasta la vista baby\n"

		.text
main:
				li $t0, 128
beginning:	
		# Opens dialog box for user input
		la 	$a0, msg			# $a0 = "Enter some text:"
		la	$a1, input		# $a1 = user input
		lw 	$a2, maxLength		# $a2 = maximum character length 
		li 	$v0, 54			# input dialog box
		syscall
		
		# Checks if string is empty, if it is: exits, else: computes characters in input
		beq 	$a1, -2, exit		# exit if cancel is hit
		beq 	$a1, -3, exit		# exit if no input
		beq 	$a1, -4, exit		# exit if input is too long

		# function call to count characters and words
		jal 	count
		sw	$v0, characters		# stores number of characters(s)
		sw 	$v1, words		# stores number of word(s)
		
		# printing the input, char count, and word count		
		li 	$v0, 4
		la 	$a0, input		# prints the input
		syscall
		
		li 	$v0, 1
		lw 	$a0, words		# prints the number of word(s)
		syscall
		
		li 	$v0, 4
		la 	$a0, printWords		# prints "word(s)"
		syscall				
		
		li 	$v0, 1
		lw 	$a0, characters		# prints the number of character(s)
		syscall
		
		li 	$v0, 4
		la 	$a0, printCharacters	# prints "character(s)\n"
		syscall
		
		j 	beginning		# keeps repeating process, so jumps to the beginning of the program
								
exit:		# goodbye to user and exits program

		li 	$v0, 59			# outputs a message dialog box
		la 	$a0, goodbye		# $a0 = goodbye message
		syscall

		li 	$v0, 10			# exits program
		syscall

count:		# Count the characters and words in the input	
		la 	$s1, input		# $s1 = user input string
		
		addi	$sp, $sp, -4		# push $s1 to stack
		sw	$s1, ($sp)

		li 	$s0, 0 			# keeps track of all characters
		li 	$s2, 0 			# keeps track of all spaces

loop:		# loop through and count characters
		lb 	$a0, 0($s1)		# the current character
		blez 	$a0, exitFunction	# exits function if end of string is reached
		addi 	$s0, $s0, 1 		# increments count of characters
		addi 	$s1, $s1, 1 		# goes to the next character in the input
		beq 	$a0, 32, countSpaces	# if the character is a space it increments the space count
		
		j 	loop		
		
countSpaces:	addi 	$s2, $s2, 1	
		j 	loop	
		
exitFunction:	
		lw	$s1, ($sp)		# pop $s1 from stack	
		addi	$sp, $sp, 4	
		
		addi 	$v0, $s0, -1 		# $v0 = character count - 1 || the -1 subtracts the \n character
		addi 	$v1, $s2, 1		# $v1 = space count + 1 || words = space + 1
		
		jr 	$ra			# returns to where function was called
		
		


	
	
	
	
