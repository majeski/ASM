.global step
.func step

.text

step:
	push {r4, r5, r6, r7, r8, r9, r10}
	ldr r1, =mm_flow_matrix
	ldr r1, [r1]
	ldr r2, =mm_flow_width
	ldr r2, [r2]
	ldr r3, =mm_flow_height
	ldr r3, [r3]
	ldr r9, =mm_flow_weight
	ldr r9, [r9]
	ldr r10, =mm_flow_tmp
	ldr r10, [r10]

@ r0 - step_tab
@ r1 - matrix
@ r2 - width
@ r3 - height
@ r9 - weight
@ r10 - tmp_tab

@ copy step_tab to first row
	mov r4, r2
first_row_loop:
	cmp r4, #0
	beq first_row_loop_end
	sub r4, #1

	ldr r5, [r0], #4
	str r5, [r1], #4
	add r10, #4

	b first_row_loop
first_row_loop_end:

@ update matrix
	mov r4, r3
	sub r4, #1

	mov r0, r3

@ get field in previous row (width * 4 bytes earlier)
	mov r6, r2
	lsl r6, #2
	mov r3, r1
	sub r3, r6

@ r0 - height
@ r1 - current field
@ r2 - width
@ r3 - prev row field
@ r4 - rows left
@ r5 - columns left
@ r9 - weight
@ r10 - current field in tmp
row_loop:
	cmp r4, #0
	beq end_row
	sub r4, #1

@ reset columns
	mov r5, r2
@ substract first & last
	sub r5, #2

@ first col
@ current row
	ldr r6, [r1]
	ldr r7, [r1, #4]!

@ previous row
	ldr r8, [r3]
	add r7, r8
	ldr r8, [r3, #4]!
	add r7, r8

@ tmp[] = sum - 3 * val
	mov r8, #3
	mul r6, r8
	sub r7, r6
	str r7, [r10], #4

col_loop:
	cmp r5, #0
	beq end_col
	sub r5, #1

@ middle col
@ current row
	ldr r8, [r1, #-4]
	ldr r6, [r1]
	ldr r7, [r1, #4]!
	add r7, r8

@ previous row
	ldr r8, [r3, #-4]
	add r7, r8
	ldr r8, [r3]
	add r7, r8
	ldr r8, [r3, #4]!
	add r7, r8

@ tmp[] = sum - 5 * val
	mov r8, #5
	mul r6, r8
	sub r7, r6
	str r7, [r10], #4

	b col_loop
end_col:

@ last col
@ currrent row
	ldr r7, [r1, #-4]
	ldr r6, [r1], #4

@ previous row
	ldr r8, [r3, #-4]
	add r7, r8
	ldr r8, [r3], #4
	add r7, r8

@ tmp[] = sum - 3 * val
	mov r8, #3
	mul r6, r8
	sub r7, r6
	str r7, [r10], #4

	b row_loop
end_row:

@ add tmp to matrix
	ldr r0, =mm_flow_matrix
	ldr r0, [r0]
	ldr r1, =mm_flow_tmp
	ldr r1, [r1]
	ldr r2, =mm_flow_width
	ldr r2, [r2]
	ldr r3, =mm_flow_height
	ldr r3, [r3]

@ array size
	mul r3, r2

@ bytes in row
	lsl r2, #2

@ start from second row
	add r0, r2
	add r1, r2

@ matrix[] += tmp[] * weight
tmp_loop:
	cmp r3, #0
	beq end_tmp_loop
	sub r3, #1

	ldr r4, [r0]
	ldr r5, [r1], #4

@ fixed mul: a * b = (a*b) >> 8
@ r5 * weight
	mul r5, r9 
	asr r5, #8

	add r4, r5
	str r4, [r0], #4

	b tmp_loop
end_tmp_loop:

	pop {r4, r5, r6, r7, r8, r9, r10}
	bx lr
