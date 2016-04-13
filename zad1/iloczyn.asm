        section .text
        extern malloc
        extern suma
        extern multiply_s
        extern multiply_ten
        global iloczyn

; (a, b) -> a * b
iloczyn:
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

        mov edi,[ebp+8] ; a
        mov esi,[ebp+12] ; b

        xor edx,edx
        mov dh,[edi+2]
        mov dl,[esi+2]

        cmp dh,dl
        je short no_sign 
; sign
        mov dl,1
        jmp short sign_end
no_sign:
        xor dl,dl
sign_end:
        push edx ; save sign

        mov ebp,eax ; result

        xor ecx,ecx

        mov cx,[esi] ; get b size
        add esi,3 ; first byte
loop_s:
        push ecx ; save size

        ; first digit
        push ebp
        call multiply_ten
        add esp,4 ; drop arg
        mov ebp,eax

        xor eax,eax
        mov al,[esi]
        and al,0xF0
        shr al,4

        test al,al
        jz skip1

        push eax ; push multiplier
        push edi ; push a
        call multiply_s
        pop edi
        add esp,4 ; drop multiplier

        push ebp ; push result
        push eax ; push multiply result
        call suma
        add esp,8 ; drop
        mov ebp,eax ; get new result

skip1:
        ; second digit
        push ebp
        call multiply_ten
        add esp,4 ; drop arg
        mov ebp,eax

        xor eax,eax
        mov al,[esi]
        and al,0x0F

        test al,al
        jz skip2

        push eax ; push multiplier
        push edi ; push a
        call multiply_s
        pop edi
        add esp,4 ; drop multiplier

        push ebp ; push result
        push eax ; push multiply result
        call suma
        add esp,8 ; drop
        mov ebp,eax ; get new result

skip2:
        inc esi
        pop ecx ; load size
        loop loop_s

        mov eax,ebp
        pop edx ; get sign

        mov bh,[eax+3]
        test bh,bh
        jz skip3
        mov [eax+2],dl

skip3:
        pop edi
        pop esi
        pop ebx ; restore registers

        pop ebp
        ret