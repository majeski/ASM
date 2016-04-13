	global start
	extern malloc

	extern mm_flow_width
	extern mm_flow_height
	extern mm_flow_matrix
	extern mm_flow_tmp
	extern mm_flow_weight

	section .text

	; saves arguments in global variables and creates transpose of a matrix
start:
	push rbp
	push rbx
	; rdi - width
	; rsi - height
	; rdx - &matrix
	; xmm0 - weight
	
	movd [mm_flow_weight], xmm0
	mov [mm_flow_width], edi
	mov [mm_flow_height], esi
	mov [mm_flow_matrix], edx

	xor rax, rax
	mov eax, edi
	imul eax, esi ; calc size

	mov rdi, rax
	add rdi, 4 ; additional space to avoid reading after table
	shl rdi, 2 ; 4 bytes per value
	mov rbx, rdi

	call malloc
	mov [mm_flow_tmp], rax

	pop rbx
	pop rbp

	ret