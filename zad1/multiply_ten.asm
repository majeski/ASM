        section .text
        extern malloc
        global multiply_ten

; (a) -> a * 10 
multiply_ten:
        push ebp
        mov ebp,esp

        push ebx
        push esi
        push edi ; save registers

        mov esi,[ebp+8] ; get a
        mov bl,[esi+3] ; first byte
        mov eax,esi
        test bl,bl ; 0?
        jz end

        test bl,0xF0
        jz simple_shift

        xor ecx,ecx
        mov cx,[esi]
        add cx,4
        push ecx
        call malloc
        add esp,4

        mov edi,eax
        xor ecx,ecx
        mov cx,[esi] ; get size
        mov [edi],cx ; save size
        add word [edi],1 ; size + 1
        mov dl,[esi+2] ; get sign
        mov [edi+2],dl ; save sign
        add esi,3
        add edi,3
        ; eax - result
        ; esi - first byte in input
        ; edi - first byte in result
        ; ecx - counter
        xor dl,dl ; carry
loop1:
        mov bh,[esi]
        shr bh,4 ; upper bits

        or bh,dl
        mov [edi],bh

        mov dl,[esi] ; get carry
        and dl,0x0F
        shl dl,4

        inc esi
        inc edi
        loop loop1

        mov [edi],dl
        jmp end

simple_shift:
        xor ecx,ecx
        mov cx,[esi]
        add cx,3
        push ecx
        call malloc
        add esp,4

        mov edi,eax
        xor ecx,ecx
        mov cx,[esi] ; get size
        mov [edi],cx ; save size
        mov dl,[esi+2] ; get sign
        mov [edi+2],dl ; save sign
        add esi,ecx
        add esi,2
        add edi,ecx
        add edi,2
        ; eax - result
        ; esi - last byte in input
        ; edi - last byte in result
        ; ecx - counter
        xor dl,dl ; carry
loop_s:
        mov bl,[esi]
        shl bl,4 ; lower bits
        or bl,dl ; shifted
        mov [edi],bl

        mov dl,[esi] ; get carry
        and dl,0xF0
        shr dl,4

        dec esi
        dec edi
        loop loop_s

end:
        pop edi
        pop esi
        pop ebx ; restore registers

        pop ebp
        ret

