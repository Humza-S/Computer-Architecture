.include		"macro_file.asm"

		.data
endl:		.ascii	"\n"
		.align 	2
prompt:		.ascii	"Please enter the file-name to compress or <enter> to exit: "
		.align	2
fileName:	.ascii "file"
		.space	21
		.align	2

origBuf:		.ascii	""
		.space	1024
		.align 	2

uncompBuf:	.ascii	""
		.space 	1024
		.align 	2

compBuf:		.word	0
originalSize:	.word 	-1
compressedSize:	.word	-1
uncompSize:	.word	-1

		
		.text
main:
		get_string_from_user (prompt, fileName)	# retrieve the file name from the user
		
		lb	$t0, fileName($0)
		lw	$t1, endl
		beq	$t0, $t1, exit		# if enter is pressed, exits program
		
		remove_new_line_char (fileName)	# it is impossible to open file when there is a \n character in the file name, so remove it
		
		open_file_reading (fileName)	# open file, fileName, for reading
		read_file ($s0, origBuf, 1024)	# s0 = file descriptor, reads into buffer, allocates 1024 bytes of dynamic memory
		sw	$v0, originalSize	# save size of original data
		add_null_terminator(origBuf, originalSize)	# add null terminator to end of input stream
		close_file(fileName)	# close file 
		
		print_string("\nOriginal data:\n")	# printing the original data
		li	$v0, 4
		la	$a0, origBuf
		syscall		
		
		all_heap_mem (1024, compBuf)	# allocate heap memory for the compressed data
		la	$a0, origBuf		# a0 = address of original data
		lw	$a1, compBuf		# a1 = address of the compression buffer
		lw	$a2, originalSize	# a2 = size of original file
		jal	compress			# call function to compress data
		sw	$v0, compressedSize	# save size of compressed data
		
		print_string("\nCompressed data:\n")	# printing the compressed data

		lw	$a1, compBuf		# a1 = address of the compression buffer
		lw	$a2, compressedSize	# a2 = size of compressed data
		jal	printData		# call function to print compressedd data
		
		lw	$a0, compBuf		# a0 = address of compressed data
		la	$a1, uncompBuf		# a1 = address of the uncompressed buffer
		lw	$a2, compressedSize	# a2 = size of the compressed data
		jal	uncompress		# call function to uncompress data	

		add_null_terminator(uncompBuf, originalSize)	# add null terminator to end of string (prevents previous data from being read)
		print_string("\nUncompressed data:\n")	# printing the uncompressed data
		li	$v0, 4
		la	$a0, uncompBuf
		syscall
		
		print_string ("\nOriginal File Size: ")	# print original file size
		lw	$t0, originalSize
		print_int ($t0)
		print_string ("\n")
		
		print_string ("Compressed File Size: ")	# print compressed file size	
		lw	$t0, compressedSize
		print_int ($t0)
		
		print_string ("\n")	# print new line
		
		j	main	# repeat program

exit:		li	$v0, 10	# exit program
		syscall

######################################## COMPRESS ##################################################
# a0 = address of input buffer
# a1 = address of compression buffer in heap
# a2 = size of original file
# returns v0 = size of compressed data
compress:	
		li	$t0, 0	# i = 0
		li	$t3, 0	# size of compressed data
		li	$t2, 10	# t2 = 10 for division, multiplication operations
		li	$t6, 0

		addi	$sp, $sp, -4	# push starting address of heap to stack
		sw	$a1, ($sp)

		j 	compLoop		# start with the first character to compress

saveByte:	sb	$t4, ($a1)	# store the character in the heap
		addi	$a1, $a1, 1	# increment heap address
		sb	$t1, ($a1)	# store the character count in the heap
		addi	$a1, $a1, 1	# increment heap address
		
		
compLoop:	bge	$t0, $a2, compSize	# if (i >= size), exit loop
		lb	$t4, ($a0)	# t4 = string.charAt(i)
		li	$t1, 1			# character count is initally 1
		
insideLoop:	bge	$t0, $a2, compSize	# if (i >= size), exit loop
		addi	$a0, $a0, 1		# next character
		addi	$t0, $t0, 1		# i++
		lb	$t5, ($a0)		# t5 = string.charAt(i+1)
		bne	$t4, $t5, saveByte	# if (t4 != t5), then loop push character and character count onto heap | str[i] != str[i+1]
		addi	$t1, $t1, 1		# character count++
		j	insideLoop

compSize:	lw	$a1, ($sp)	# pop starting address of heap from stack
		addi	$sp, $sp, 4
		
		li	$t3, 0	# size of compressed data
	
countLoop:	lb	$t0, ($a1)	# load character	
		blez	$t0, ret		# if \0, then return
		addi	$t3, $t3, 1	# increment total character count
		addi	$a1, $a1, 1	# next character
		j	countLoop

ret:		addi	$v0, $t3, 0		# v0 = size of compressed data
		jr	$ra

######################################## UNCOMPRESS ################################################
# a0 = address of input buffer in heap
# a1 = address of ouput buffer in static memory
# a2 = size of compressed data

uncompress:	
		li	$t0, 0

uncompLoop:	beq	$t0, $a2, uncompRet	# if (i == size) then return
		lb	$t1, ($a0)	# t1 = string.charAt(i) | load character
		addi	$a0, $a0, 1	# increment the input buffer address
		lb	$t2, ($a0)	# t2 = string.charAt(i) | load character count
		addi	$a0, $a0, 1	# increment the input buffer address
		addi	$t0, $t0, 2	# t0 += 2 | increment by 2 because we take pairs
		
		li 	$t3, 0	# j = 0
saveToMem:	beq	$t3, $t2, uncompLoop # if (j == character count) then loop again to get new character, character count pair
		sb	$t1, ($a1)	# store the character in the output memory
		addi	$a1, $a1, 1	# increment the output memory address
		addi	$t3, $t3, 1	# j++
		j 	saveToMem

uncompRet:	jr	$ra
		
############################### PRINT COMPRESSED DATA ##############################################
# a1 = address of compressed buffer in heap
# a2 = size of compressed data

printData:	#move	$t0, $a0	# load compressed buffer address

		li	$t1, 0	# i = 0
		#move	$t2, $a1		# load compressed size
printComp:	beq	$t1, $a2, donePrinting	# if ( i == compressed size ) then return
		lb	$t3, ($a1)	# save the character to print
		print_char($t3)		# print character		
		addi	$a1, $a1, 1	# increment the address 
		lb	$t3, ($a1)	# save the character count to print
		print_int($t3)		# print integer
		addi	$a1, $a1, 1	# increment the address
		addi	$t1, $t1, 2	# increment t1 to get next pair
		j 	printComp

donePrinting:	jr	$ra






