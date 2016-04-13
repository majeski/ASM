        section .text
        extern malloc
        global negation

; (x) -> -x
negation:
        push ebp
        mov ebp,esp

        push ebx
        push esi
        push edi ; save registers

        mov ebx,[ebp+8]
        xor ecx,ecx
        mov cx,[ebx] ; get size
        add cx,3 ; size (2 bytes), sign (1 byte) 
        push ecx
        call malloc
        pop ecx
        sub cx,3
        ; cx - size
        ; eax - result
        mov [eax],cx ; set size
        mov dh,[ebx+2] ; get sign
        xor dh,1 ; reverse sign
        mov [eax+2],dh ; set sign

        push eax ; save result
        add ebx,3 ; first digit in original value
        add eax,3 ; first digit in result value

loop_s:
        mov dl,[ebx]
        mov [eax],dl
        inc ebx
        inc eax
        loop loop_s

        pop eax ; get result

        pop edi
        pop esi
        pop ebx ; restore registers

        pop ebp
        ret

