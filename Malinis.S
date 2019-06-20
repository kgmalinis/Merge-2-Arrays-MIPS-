# Kate Malinis	<kgm170030>
# CS 3340 -- Assignment 3
# This program should merge two arrays and output a combined list in ascending order.

.data
	arr1:	.word	1, 4, 6, 9	# arr1 contents
	arr2:	.word	0, 2, 3, 7	# arr2 contents
	merged_array:	.word	8	# length of array (elements in arr1 + elements in arr2) goes here	
	space:	.asciiz	" "

.text
.globl main

main:
	la	$a0, arr1	# load the start address of first array 
	la	$a1, arr2	# load the start address of the second array
	lw	$t0, merged_array	# load the merged array length
	sll	$t0, $t0, 2	# multiply array length by 4
	add	$a2, $a0, $a1	# calculating array start address
	add	$a3, $a2, $t0	# calculate array end address
	jal	merge_sort	# call merge_sort function
	b	finish_sort	# done sorting

merge_sort:
	# $a2 -- start address
	# $t0 -- length of array
	# $a3 -- end address
	
	addi	$sp, $sp, -16	# adjust stack pointer
	sw	$ra, 0($sp)	# store return address on stack
	sw	$a2, 4($sp)	# store first address of array on stack
	sw	$a3, 8($sp)	# store last address of array on stack

	sub	$t0, $a3, $a2	# calculate difference between start and end addresses

	ble	$t0, 4, merge_end	# if array only has single element --> merge_end

	srl	$t0, $t0, 3	# divide array size by 8 to get half of the elements (shift right 3 bits)
	sll	$t0, $t0, 2	# multiply by 4 to get half of that array size (shift left 2 bits)
	add	$a3, $a2, $t0	# calculate midpoint address of the array
	sw	$a3, 12($sp)	# store midpoint address 

	jal	merge_sort	# recursive call

	lw	$a2, 12($sp)	# load midpoint address from stack
	lw	$a3, 8($sp)	# load end address of array from stack

	jal	merge_sort	# recursive call

	lw	$a2, 4($sp)	# load array start address from stack
	lw	$a3, 12($sp)	# load array midpoint address from stack
	lw	$a1, 8($sp)	# load array end address from stack

	jal	merge_halves	# call merge_halves to merge the array halves

merge_end:
	lw	$ra, 0($sp)	# load return address from stack
	addi	$sp, $sp, 16	# adjust stack pointer
	jr	$ra	

merge_halves:
	# $a2 -- first address
	# $a3 -- first address of second array
	# $a1 -- last address of second array
	addi	$sp, $sp, -16	# adjust stack pointer
	sw	$ra, 0($sp)	# store return address on stack
	sw	$a2, 4($sp)	# store start address on stack
	sw	$a3, 8($sp)	# store midpoint address on stack
	sw	$a1, 12($sp)	# store end address on stack

	move	$s0, $a2	# create copy of first half addresses
	move	$s1, $a3	# create copy of second half addresses

merge_halves_loop:
	lw	$t0, 0($s0)	# load first half position
	lw	$t1, 0($s1)	# load second half position
	lw	$t0, 0($t0)	# load first half position value
	lw	$t1, 0($t1)	# load second half position value

	bgt	$t1, $t0, no_shift	# if lower value is already first, do not shift

	move	$a2, $s1	# load argument for element to move
	move	$a3, $s0	# load argument for address to move it
	jal	shift_element	# call shift_element to shift element to new position

	addi	$s1, $s1, 4	# increment second half index

no_shift:
	addi	$s0, $s0, 4	# increment first half index
	
	lw	$a1, 12($sp)	# reload end address
	bge	$s0, $a1, end_merge_loop	# end loop if halves are empty
	bge	$s1, $a1, end_merge_loop	# end loop if halves are empty
	b	merge_halves_loop

end_merge_loop:
	lw	$ra, 0($sp)	# load return address
	addi	$sp, $sp, 16	# adjust stack pointer
	jr $ra

shift_element:
	li	$t0, 10	
	ble	$a0, $a1, end_shift_element	# if we are at correct location, stop shifting
	addi	$t6, $a0, -4	# find previous address in array
	lw	$t7, 0($a0)	# get current pointer
	lw	$t8, 0($t6)	# get previous pointer
	sw	$t7, 0($t6)	# save current pointer to previous address
	sw	$t8, 0($a0)	# save previous pointer to current address
	move	$a0, $t6	# shift current position back
	b	shift_element	#  recursive call

end_shift_element:
	jr	$ra

finish_sort:
	# point to jump when sorting is complete

# print out indirect array
	li	$t0, 0		# initialize current index

print_array:
	lw	$t1, merged_array	# load array length
	bge	$t0, $t1, finish_printing	# if at end of array, we are done
	sll	$t2, $t0, 2	# multiply index by 4
	lw	$t3, merged_array($t2)	# get the pointer
	lw	$a0, 0($t3)	# get the value pointed to and store for printing
	li	$v0, 1
	syscall		# print the value
	la	$a0, space
	li	$v0, 4
	syscall		# print the value
	addi	$t0, $t0, 1	# increment index by 1
	b	print_array	# recursive call

finish_printing:
	li	$v0, 10
	syscall