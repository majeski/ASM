	global step

	extern mm_flow_width
	extern mm_flow_height
	extern mm_flow_matrix
	extern mm_flow_weight
	extern mm_flow_tmp

	section .text

step:
	push rbp
	push rbx

	movd xmm3, [mm_flow_weight]
	shufps xmm3, xmm3, 0h
	; mask: w w w w
	xor eax, eax
	cvtsi2ss xmm3, eax
	; mask: 0 w w w
	shufps xmm3, xmm3, 39h
	; xmm3 - w w w 0

	; rdi - &(step table)
	; r8 - &matrix

	mov ecx, [mm_flow_width]
	mov ebx, ecx
	mov r8, [mm_flow_matrix]

	mov r9, r8
first_col:
	mov eax, [rdi]
	mov [r9], eax
	add rdi, 4
	add r9, 4
	loop first_col

	mov ecx, [mm_flow_height]
	; ebx - width
	; ecx - height
	; r8 - &matrix

	mov edi, ecx 
	sub edi, 1
	imul edi, ebx
	; edi - width * (height - 1)

	xor rax, rax
	mov eax, ebx 
	shl eax, 2 ; 4 bytes per value
	; eax - bytes in row

	mov r15, [mm_flow_tmp]
	; r15 - &tmp
	add r8, rax
	dec ecx ; ignore first row
	sub ebx, 2
	; ebx - width - 2

	mov r11, r8 ; first value in matrix
	mov r12, r15 ; first value in tmp
loop_row:
	test ecx, ecx
	jz add_loop
	
	mov edx, ebx
	mov r9, r8
	; edx - num of columns left
	; r9 - current position
	; r15 - position in tmp

; first cell in row
	mov r10, r9
	sub r10, rax
	movups xmm0, [r9]
	movups xmm1, [r10]
	; xmm0 - current row
	; xmm1 - prev row
	movd xmm2, [r9]
	shufps xmm2, xmm2, 0h
	movaps xmm4, xmm2
	; xmm2: r r r r
	; xmm4: r r r r

	subps xmm4, xmm1
	subps xmm2, xmm0 ; substract from value in current cell

	addps xmm4, xmm2
	mulps xmm4, xmm3 ; apply mask
	
	haddps xmm4, xmm4 ; a b c d -> _ _ _ c+d

	movd esi, xmm4 
	mov [r15], esi
	add r15, 4

loop_cols:
	test edx, edx
	jz last_row_cell

	mov r10, r9
	sub r10, rax
	movups xmm0, [r9]
	movups xmm1, [r10]
	; xmm0 - current row
	; xmm1 - prev row
	add r9, 4
	movd xmm2, [r9]
	shufps xmm2, xmm2, 0h
	movaps xmm4, xmm2
	; xmm2: r r r r
	; xmm4: r r r r

	subps xmm4, xmm1
	subps xmm2, xmm0 ; substract from value in current cell

	addps xmm4, xmm2
	mulps xmm4, xmm3 ; apply mask

	haddps xmm4, xmm4 ; a b c d -> _ _ a+b c+d
	haddps xmm4, xmm4 ; _ _ a+b c+d -> _ _ _ a+b+c+d

	movd esi, xmm4
	mov [r15], esi
	add r15, 4

	dec edx
	jmp loop_cols

last_row_cell:
	mov r10, r9
	sub r10, rax
	movups xmm0, [r9]
	movups xmm1, [r10]
	; xmm0 - current row
	; xmm1 - prev row
	add r9, 4
	movd xmm2, [r9]
	shufps xmm2, xmm2, 0h
	movaps xmm4, xmm2
	; xmm2: r r r r
	; xmm4: r r r r

	subps xmm4, xmm1
	subps xmm2, xmm0 ; substract from value in current cell

	addps xmm4, xmm2
	mulps xmm4, xmm3 ; apply mask

	haddps xmm4, xmm4 ; a b c d -> _ _ _ c+d

	movd esi, xmm4 
	mov [r15], esi
	add r15, 4

	add r8, rax
	dec ecx
	jmp loop_row

; time to add tmp to matrix
	; r11 - matrix (second row)
	; r12 - tmp
	; edi - width * (height - 1)
add_loop:
	cmp edi, 0
	jle end

	movups xmm0, [r11]
	movups xmm1, [r12]
	addps xmm0, xmm1
	movups [r11], xmm0
	add r11, 16
	add r12, 16
	sub edi, 4
	jmp add_loop

end:
	pop rbx
	pop rbp

	ret