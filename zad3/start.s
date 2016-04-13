.data

.global start
.global malloc

.text

start:
	push {r4, lr}
	ldr r4, =mm_flow_width
	str r0, [r4]

	ldr r4, =mm_flow_height
	str r1, [r4]

	ldr r4, =mm_flow_matrix
	str r2, [r4]

	ldr r4, =mm_flow_weight
	str r3, [r4]

	mul r2, r0, r1
	lsl r2, #2
	mov r0, r2
	@ call malloc(width * height * 4)
	bl malloc

	ldr r4, =mm_flow_tmp
	str r0, [r4]

	pop {r4, lr}
	bx lr
