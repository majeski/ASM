        section .bss
LONG_B  resd 1
SHORT_B resd 1

        section .text
        extern malloc
        extern roznica
        extern negation
        global suma

suma:
        push ebp
        mov ebp,esp

        push ebx
        push esi
        push edi ; save registers

        mov ecx,[ebp+8] ; temporary longer ; first arg
        mov edx,[ebp+12] ; temporary shorter ; second arg

        mov al,[ecx+2]
        mov ah,[edx+2]
        cmp al,ah
        je check_size
        
        cmp al,1
        jne minus2
; -a + b
        mov ebx,edx
        push ecx
        call negation
; a + b 
        pop ecx
        push eax ; a
        push ebx ; b
; call with: b - a
        jmp call_roznica
minus2: 
; a + -b
        mov ebx,ecx
        push edx
        call negation
        add esp,4 ; drop arg
; a + b 
        push eax ; b
        push ebx ; a
; call with: a - b

call_roznica:
        call roznica
        add esp,8 ; drop args

        pop edi
        pop esi
        pop ebx ; restore registers

        pop ebp
        ret

check_size:
        mov ax,[ecx] ; get size
        cmp ax,[edx] ; compare to the other value size
        jge short skip_swap
        mov edi,edx
        mov edx,ecx
        mov ecx,edi ; swap ptrs

skip_swap:
        mov [LONG_B],ecx ; save longer number
        mov [SHORT_B],edx ; save shorter number

        xor eax,eax
        mov ax,[ecx] ; get longer length 
        add eax,4 ; size (2 bytes); +/- (1 byte); additional place (1 byte) for longer result

        push eax
        call malloc
        pop edx ; get result length
        push eax ; save result

        mov edi,eax
        add edi,edx
        dec edi
        ; edi - last digit (result)  

        mov ecx,[LONG_B]
        mov edx,[SHORT_B]

        xor eax,eax
        mov ax,[edx]
        add edx,eax
        add edx,2
        ; edx - last digit (shorter)

        mov ax,[ecx]
        add ecx,eax
        add ecx,2
        ; ecx - last digit (longer)

        xor eax,eax
while1:
        push eax ; save eax (and ah, and flags in ah)
        mov eax,[LONG_B]
        add eax,2
        cmp ecx,eax
        je short end1 ; end of value?

        mov bh,0

        mov eax,[SHORT_B]
        add eax,2
        cmp edx,eax
        je short skip_get

        mov bh,[edx] ; get digit from shorter value
        dec edx

skip_get:
        mov bl,[ecx] ; get digit from longer value
        dec ecx

        ; bh, bl - values to add

        pop eax ; load eax (and ah, and flags in ah)
        sahf ; load flags
        mov al,bl
        adc al,bh
        daa
        lahf ; save flags
        mov [edi],al
        dec edi

        jmp while1

end1:
        xor bx,bx
        pop eax ; load eax (and ah, and flags in ah)
        sahf ; load flags
        adc bl,0 ; get carry
        mov [edi],bl ; save carry
        mov ecx,[LONG_B] ; get longer
        mov dx,[ecx] ; get longer size
        mov cl,[ecx+2] ; get sign
        mov [edi-1],cl ; set sign

        add dx,bx ; increase size if carry existed

        test bl,bl
        pop eax ; get result
        jnz short finale ; if carry

        mov cl,[eax+2] ; get sign
        mov [eax+3],cl ; shift right sign
        inc eax ; drop first byte

finale:
        mov [eax],dx ; save size

        pop edi
        pop esi
        pop ebx ; restore registers

        pop ebp
        ret