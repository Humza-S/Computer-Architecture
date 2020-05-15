# file for macros

######## print int ########
.macro	print_int (%x)
	li	$v0, 1		# syscall for printing int
	add	$a0, $0, %x
	syscall
.end_macro

######## print char ########
.macro	print_char (%c)		
	li	$v0, 11		# syscall for printing char
	move	$a0, %c
	syscall
.end_macro

######## print string ########
.macro	print_string (%str)	
	.data
str:	.ascii	%str		# allocate memory for string
	.space 	100
	.align 	2
	.text
	li	$v0, 4		# syscall for printing string
	la	$a0, str
	syscall
.end_macro

######## get file from user ########
.macro 	get_string_from_user (%prompt, %inputBuf)
	li	$v0, 4			# system call for printing string
	la	$a0, %prompt		# prompt user for input
	syscall
	
	li	$v0, 8			# system call for reading string
	la	$a0, %inputBuf		# address of input buffer
	li	$a1, 21			# maximum numbers of characters to read is 20, excluding \n
	syscall	
.end_macro

######## remove new line character ########
.macro	remove_new_line_char (%word)
	li 	$t0, 0		# i = 0
removeNewLineChar:
	lb 	$t1, %word($t0)	# t1 = string.charAt(i)
	addi 	$t0, $t0, 1	# i++
	bnez 	$t1, removeNewLineChar     # loop until end of string
	beqz 	$t0, endRemoval  # Do not remove \n when string = maxlength
	addi 	$t0, $t0, -2     # go back two addresses to '\n'
	sb 	$0, %word($t0)    # replace '\n' with '\0'
endRemoval:
.end_macro
	
######## add null terminator ########	
.macro	add_null_terminator (%word, %size)
	lw	$t1, %size	# t1 = size
	addi	$t1, $t1, 1	# t1 += 1
	sb	$0, %word($t1)	# make next byte a '\0' character to add null termination
.end_macro

######## open file for reading ########	
.macro	open_file_reading (%file)
	.text
	li   	$v0, 13       		# system call for open file
  	la   	$a0, %file	    	# input file name
  	li   	$a1, 0        		# 0 flag means it is for reading
 	li   	$a2, 0        		# mode is ignored
 	syscall
 	
 	bgez	$v0, moveFD		# if v0 >= 0, then file has opened and jump
 	print_string ("The program encountered an error while opening the file for reading. Exiting program.\n")
 	
 	li	$v0, 10			# exit program since error opening file
 	syscall	
 	
moveFD:	move	$s0, $v0			# save the file descriptor in $t1
.end_macro

######## read file ########	
.macro	read_file (%file, %buffer, %x)
	li   	$v0, 14       		# system call for file read
  	move	$a0, %file    		# file descriptor 
  	la	$a1, %buffer  		# address of buffer to read into
  	la  	$a2, %x      		# buffer length
  	syscall
  	
  	bgt	$v0, 0, after		# if $v0 (bytes read) <= 0, then output error, and exit program.
	print_string ("The program encountered an error while reading the file. Exiting program.\n")
	
	li	$v0, 10			# exit program since error opening file
 	syscall	
after:
.end_macro

######## close file ########
.macro	close_file (%file)
	li	$v0, 16			# system call for closing file
	la	$a0, %file		# file descriptor
	syscall
.end_macro

######## allocate heap memory ########
.macro	all_heap_mem (%x, %buffer)
	li	$v0, 9			# system call for allocating memory on heap
	la	$a0, %x			# number of bytes to allocate
	syscall
	sw	$v0, %buffer		# save pointer of address to buffer
.end_macro
