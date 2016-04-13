        section .data
SIGN    db 0

        section .bss
LONG_B  resd 1
SHORT_B resd 1

        section .text
        extern malloc
        extern isgreater
        extern negation
        extern suma
        global roznica

roznica:
        push ebp
        mov ebp,esp

        push ebx
        push esi
        push edi ; save registers

        mov eax,[ebp+12]
        push eax
        mov eax,[ebp+8]
        push eax

        call isgreater
        test eax,eax
        jnz short normal

; reverse
        call negation ; negate value on stack
        add esp,4 ; drop argument
        mov ebx,eax
        call negation ; negate value on stack
        add esp,4 ; drop argument

        mov ecx,eax
        mov edx,ebx

        jmp after_cmp
normal:
        pop ecx
        pop edx

after_cmp:

        ; ecx - first (greater)
        ; edx - second

        mov ah,[ecx+2] ; get sign
        mov [SIGN],ah ; save sign

        mov al,[edx+2] ; get sign
        cmp ah,al
        je skip_add
; a - -b -> a + b
; -a - b -> -a + -b
        mov ebx,ecx ; save a
        push edx ; negate b
        call negation
        add esp,4 ; drop argument

        push ebx ; a
        push eax ; b

        call suma
        add esp,8 ; drop arguments

        pop ebx
        pop esi
        pop edi ; save registers

        pop ebp
        ret

skip_add:
; -a - -b -> b - a
; a - b

        mov [LONG_B],ecx
        mov [SHORT_B],edx ; save values

        xor eax,eax
        mov ax,[ecx] ; get size
        add eax,3 ; place for size (2 bytes) and sign (1 byte)
        push eax
        call malloc
        mov edi,eax

        pop eax ; get size
        add edi,eax
        dec edi

        ; edi - last digit in result

        mov ecx,[LONG_B]
        mov edx,[SHORT_B]

        xor eax,eax
        mov ax,[ecx]
        add ecx,eax
        add ecx,2
        ; ecx - last digit in greater value

        mov ax,[edx]
        add edx,eax
        add edx,2
        ; edx - last digit in smaller value

        xor eax,eax
        xor esi,esi ; to store size in si
while1:
        push eax ; save eax (and ah, and flags in ah)
        mov eax,[LONG_B]
        add eax,2
        cmp ecx,eax
        je short end1 ; end of value?

        xor bh,bh

        mov eax,[SHORT_B]
        add eax,2
        cmp edx,eax
        je short skip_get

        mov bh,[edx] ; get digit from shorter value
        dec edx

skip_get:
        mov bl,[ecx] ; get digit from longer value
        dec ecx

        ; bh, bl - values to sub

        pop eax ; load eax (and ah, and flags in ah)
        sahf ; load flags
        mov al,bl
        sbb al,bh
        das
        lahf ; save flags
        mov [edi],al
        dec edi
        inc si
        jmp while1
end1:
        pop eax ; ignore flags

while2: ; remove zeros
        cmp si,1
        je short end2

        mov al,[edi+1]
        test al,al
        jnz short end2

        inc edi
        dec si
        jmp short while2

end2:

        sub edi,2

        mov [edi],si ; save size
        mov ah,[SIGN]
        mov al,[edi+3] ; get first digit
        test al,al
        jnz skip1
        xor ah,ah
skip1:

        mov [edi+2],ah ; save sign
        mov eax,edi

        pop edi
        pop esi
        pop ebx ; restore registers

        pop ebp
        ret