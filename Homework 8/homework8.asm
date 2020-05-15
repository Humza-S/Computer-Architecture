# Author: Humza Salman
# Class: CS 3340.502

# HOW TO RUN
	# 1. Tools > BitMap Display
	# 2. Tools > Keyboard and Display MMIO Simulator
	# 3. Bitmap Display Settings:
		# 3.1. Unit Width in Pixels: 4
		# 3.1. Unit Height in Pixels: 4
		# 3.1. Display Width in Pixels: 256
		# 3.1. Display Height in Pixels: 256
		# 3.1. Base address for display: 0x10008000($gp)
	# 4. Hit "Connect to MIPS" on Bitmap Display and the Keyboard and Display MMI OSimulator
	# 5. Assemble program
	# 6. Run the current program (this file).
	# 7. Use the KEYBOARD input on the Keyboard and Display MMIO Simulator to 
	#    input w, a, s, or d to move the square up, down, left, or right, respectively, by one pixel.  
	#    Input a spacebar to exit the program.
	
# CONSTANTS:
	.eqv	WIDTH	64 # width of screen in pixels
	.eqv	HEIGHT	64 # hiehgt of screen in pixels
	.eqv	MEM	0x10008000 # memory address of pixel(0, 0)

	# colors
	.eqv	RED	0x00FF0000
	.eqv	GREEN	0x0000FF00
	.eqv	BLUE	0x000000FF
	.eqv	WHITE	0x00FFFFFF
	.eqv	YELLOW	0x00FFFF00
	.eqv	CYAN	0x0000FFFF
	.eqv	MAGENTA	0x00FF00FF
	.eqv	BLACK	0x00000000

.data
colors:	.word	RED, GREEN, BLUE, WHITE, YELLOW, CYAN, MAGENTA	# array of colors
black:	.word	BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK	# array of only black
	
.text
	la	$a0, WIDTH	# initial x-coord
	la	$a1, HEIGHT	# initial y-coord
	sra	$a0, $a0, 1	# x-coord = width/2
	sra	$a1, $a1, 1	# y-coord = height / 2

	li	$s4, 0		# start color
	
main_loop:
	la	$a2, colors	# initial color
	jal	draw_square	# draw square
	
	addi	$sp, $sp, -4
	sw	$a0, 0($sp)	# save a0 (x-coord) to stack
	
	li	$v0, 32		# sleep for 5 ms
	li	$a0, 5
	syscall
	
	lw	$a0, 0($sp)	# load a0 (x-coord) from stack
	addi	$sp, $sp, 4
	
	lw	$t0, 0xffff0000		# t0 holds if input is available
	beq	$t0, 0, main_loop	# if t0 = 0, then no input
	
	lw	$s6, 0xffff0004	# load input
	beq	$s6, 32, exit	# space
	beq	$s6, 119, up	# w
	beq	$s6, 97, left	# a
	beq	$s6, 115, down	# s
	beq	$s6, 100, right	# d
	j 	main_loop	

exit:	li	$v0, 10
	syscall
	
#################################################
# subroutine to translate the square up by one pixel
up:
	la	$a2, black	# array of only black 
	jal	draw_square	# blacking out the square
	
	addi	$a1, $a1, -1	# new y-coord position is up one pixel
	j 	main_loop

#################################################
# subroutine to translate the square down by one pixel
down:
	la	$a2, black	# array of only black 
	jal	draw_square	# blacking out the square
	
	addi	$a1, $a1, 1	# new y-coord position is down one pixel
	j 	main_loop

#################################################
# subroutine to translate the square left by one pixel
left:
	la	$a2, black	# array of only black 
	jal	draw_square	# blacking out the square
	
	addi	$a0, $a0, -1	# new x-coord position is left one pixel
	j 	main_loop
	
#################################################
# subroutine to translate the square right by one pixel
right:
	la	$a2, black	# array of only black 
	jal	draw_square	# blacking out the square
	
	addi	$a0, $a0, 1	# new x-coord position is right one pixel
	j 	main_loop
	
#################################################
# subroutine to draw the square
# a0 = x-coord of top left pixel
# a1 = y-coord of top left pixel
# a2 = color(s)

draw_square:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)	# save return address to stack pointer

	move	$s0, $a0		# s0 = x-coord
	move	$s1, $a1		# s1 = y-coord
	move	$s2, $a2		# s2 = color(s)
	
	li	$s3, 7		# 7 pixels per side of the square
	
	sll	$s5, $s3, 2	# s5 = 7 * 4
	add	$s5, $s5, $s2	# address of last color in colors array
	
	# draw each side of the square	
	jal	draw_top_pixels
	jal	draw_left_pixels
	jal	draw_bottom_pixels
	jal	draw_right_pixels
	
	move	$a0, $s0		# a0 = x-coord
	move	$a1, $s1		# a1 = y-coord
	
	addi	$s4, $s4, 1	# increment starting color
	
	bne	$s4, $s3, exit_square # if starting color == 7, then starting color = 0
	li	$s4, 0	# starting color = 0
	
	
exit_square:
	lw	$ra, 0($sp)	# load return address from stack
	addi	$sp, $sp, 4	
	
	jr	$ra	# return
		
#################################################
# subroutine to draw the top row of pixels of the square
draw_top_pixels:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)	# push return address to stack
	
	li	$t0, 0		# i = 0
	move	$a0, $s0		# a0 = x-coord
	move	$a1, $s1		# a1 = y-coord
	move	$t2, $s2		# t2 = base address of color array

	sll	$t3, $s4, 2	# t3 = 4 * starting color index
	add	$t3, $t2, $t3 	# t3 = base colors array address + offset
	
	
draw_top_pixels_loop:
	beq	$t0, $s3, quit_draw_top	# if i == 7, quit loop
	lw	$a2, ($t3)	# load the color
	jal	draw_pixel	# call function to draw loop	
	addi	$a0, $a0, 1	# increment the x-coordinate
	addi	$t0, $t0, 1	# i++
	addi	$t3, $t3, 4	# get the next color
	bne	$t3, $s5, t_loop	# if t3 != last address of color array, keep looping
	move	$t3, $t2		# t3 = base address of color array
t_loop:	j 	draw_top_pixels_loop
	
quit_draw_top:	
	lw	$ra, 0($sp)	# load return address
	addi	$sp, $sp, 4
	jr	$ra		# return

#################################################
# subroutine to draw the right row of pixels of the square
draw_right_pixels:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)	# push return address to stack
	
	li	$t0, 0		# i = 0
	move	$a0, $s0		# a0 = x-coord
	move	$a1, $s1		# a1 = y-coord
	move	$t2, $s2		# t2 = base address of color array

	sll	$t3, $s4, 2	# t3 = 4 * starting color index
	add	$t3, $t2, $t3 	# t3 = base colors array address + offset
	
	addi	$a0, $a0, 7	# offset x-coord to the right by 7 pixels
	
draw_right_pixels_loop:
	beq	$t0, $s3, quit_draw_right	# if i == 7, quit loop
	lw	$a2, ($t3)	# load the color
	jal	draw_pixel	# call function to draw loop	
	addi	$a1, $a1, 1	# increment the y-coordinate
	addi	$t0, $t0, 1	# i++
	addi	$t3, $t3, 4	# get the next color
	bne	$t3, $s5, r_loop	# if t3 != last address of color array, keep looping
	move	$t3, $t2		# t3 = base address of color array
r_loop:	j 	draw_right_pixels_loop
	
quit_draw_right:	
	lw	$ra, 0($sp)	# load return address
	addi	$sp, $sp, 4
	jr	$ra		# return

#################################################
# subroutine to draw the bottom row of pixels of the square
draw_bottom_pixels:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)	# push return address to stack
	
	li	$t0, 0		# i = 0
	move	$a0, $s0		# a0 = x-coord
	move	$a1, $s1		# a1 = y-coord
	move	$t2, $s2		# t2 = base address of color array

	sll	$t3, $s4, 2	# t3 = 4 * starting color index
	add	$t3, $t2, $t3 	# t3 = base colors array address + offset
	
	addi	$a0, $a0, 7	# offset x-coord to the right by 1 pixel
	addi	$a1, $a1, 7	# offset y-coord to the bottom by 7 pixels
	
draw_bottom_pixels_loop:
	beq	$t0, $s3, quit_draw_bottom	# if i == 7, quit loop
	lw	$a2, ($t3)	# load the color
	jal	draw_pixel	# call function to draw loop	
	addi	$a0, $a0, -1	# decrement the x-coordinate
	addi	$t0, $t0, 1	# i++
	addi	$t3, $t3, 4	# get the next color
	bne	$t3, $s5, b_loop	# if t3 != last address of color array, keep looping
	move	$t3, $t2		# t3 = base address of color array
b_loop:	j 	draw_bottom_pixels_loop
	
quit_draw_bottom:	
	lw	$ra, 0($sp)	# load return address
	addi	$sp, $sp, 4
	jr	$ra		# return
			
################################################
# subroutine to draw the left row of pixels of the square
draw_left_pixels:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)	# push return address to stack
	
	li	$t0, 0		# i = 0
	move	$a0, $s0		# a0 = x-coord
	move	$a1, $s1		# a1 = y-coord
	move	$t2, $s2		# t2 = base address of color array

	sll	$t3, $s4, 2	# t3 = 4 * starting color index
	add	$t3, $t2, $t3 	# t3 = base colors array address + offset
	
	addi	$a1, $a1, 7	# offset y-coord to the bottom by 7 pixel
	
draw_left_pixels_loop:
	beq	$t0, $s3, quit_draw_left	# if i == 7, quit loop
	lw	$a2, ($t3)	# load the color
	jal	draw_pixel	# call function to draw loop	
	addi	$a1, $a1, -1	# decrement the y-coordinate
	addi	$t0, $t0, 1	# i++
	addi	$t3, $t3, 4	# get the next color
	bne	$t3, $s5, l_loop	# if t3 != last address of color array, keep looping
	move	$t3, $t2		# t3 = base address of color array
l_loop:	j 	draw_left_pixels_loop
	
quit_draw_left:	
	lw	$ra, 0($sp)	# load return address
	addi	$sp, $sp, 4
	jr	$ra		# return			
			
#################################################
# subroutine to draw a pixel
# a0 = x-coord
# a1 = y-coord
# a2 = color of pixel
draw_pixel:
	# t9 (address) = MEM + 4*(x + y*width)
	mul	$t9, $a1, WIDTH	  # y-coord * WIDTH
	add	$t9, $t9, $a0	  # add x-coord
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, MEM	  # add to base address
	sw	$a2, 0($t9)	  # store color at memory location
	jr 	$ra		  # return
