        section .text
        extern malloc
        extern dodaj
        extern multiply_s
        extern multiply_ten
        extern isgreater
        extern roznica
        extern negation
        global iloraz

; (a, b) -> a / b
iloraz:
        push ebp
        mov ebp,esp

        push ebx
        push esi
        push edi ; save registers

        push dword 4 ; place for zero
        call malloc
        add esp,4 ; drop arg
        mov word [eax],1
        mov byte [eax+2],0
        mov byte [eax+3],0

        mov edi,[ebp+8]
        mov esi,[ebp+12]
        mov ebp,eax

        push dword 4 ; place for zero
        call malloc
        add esp,4 ; drop arg
        mov word [eax],1
        mov byte [eax+2],0
        mov byte [eax+3],0
        mov ebx,eax

        mov al,[edi+2]
        mov dl,[esi+2]

        xor ecx,ecx ; set sign 0
        cmp al,dl
        jz skip_sign
        mov ecx,1 ; set sign 1
skip_sign:
        push ecx ; save sign

        mov al,[esi+2] ; get sign
        test al,al
        jz skip_neg

        push esi
        call negation
        add esp,4 ; drop arg
        mov esi,eax

skip_neg:
        xor ecx,ecx
        mov cx,[edi] ; get size
        add edi,3

        ; edi - current digit (ptr to a)
        ; esi - b
        ; ebp - result
        ; ebx - temporary

main_loop:
        push ecx
        
        ; first digit
        ; intro
        push ebp
        call multiply_ten
        add esp,4
        mov ebp,eax

        push ebx
        call multiply_ten
        add esp,4
        mov ebx,eax

        xor eax,eax
        mov al,[edi] ; get byte
        shr al,4 ; get higher bits

        xor ecx,ecx
        mov cx,[ebx] ; get size
        mov edx,ebx
        add edx,2
        add edx,ecx ; get last place
        or [edx],eax ; insert digit

        xor cl,cl
        ; while ebx is greater than esi
while1:
        push ecx ; save counter

        push ebx
        push esi
        call isgreater
        add esp,8 ; drop args

        pop ecx ; load counter

        test eax,eax
        jnz end_while1 ; !(esi > ebx)

        inc cl

        push ecx ; save counter

        push esi
        push ebx
        call roznica
        add esp,8 ; drop args
        mov ebx,eax ; new ebx

        pop ecx ; load counter

        jmp while1

end_while1:
        xor eax,eax
        mov ax,[ebp] ; get size
        mov edx,ebp
        add edx,2
        add edx,eax ; get last place
        or [edx],cl

        ; second digit
        ; intro
        push ebp
        call multiply_ten
        add esp,4
        mov ebp,eax

        push ebx
        call multiply_ten
        add esp,4
        mov ebx,eax

        xor eax,eax
        mov al,[edi] ; get byte
        and al,0x0F ; get lower bits

        xor ecx,ecx
        mov cx,[ebx] ; get size
        mov edx,ebx
        add edx,2
        add edx,ecx ; get last place
        or [edx],eax ; insert digit

        xor cl,cl
        ; while ebx is greater than esi
while2:
        push ecx ; save counter

        push ebx
        push esi
        call isgreater
        add esp,8 ; drop args

        pop ecx ; load counter

        test eax,eax
        jnz end_while2 ; !(esi > ebx)

        inc cl

        push ecx ; save counter

        push esi
        push ebx
        call roznica
        add esp,8 ; drop args
        mov ebx,eax ; new ebx

        pop ecx ; load counter

        jmp while2

end_while2:
        xor eax,eax
        mov ax,[ebp] ; get size
        mov edx,ebp
        add edx,2
        add edx,eax ; get last place
        or [edx],cl

        inc edi
        pop ecx
        dec ecx
        test ecx,ecx
        jnz main_loop

        pop ecx ; get sign
        mov eax,ebp
        mov [eax+2],cl

        pop edi
        pop esi
        pop ebx ; restore registers

        pop ebp
        ret