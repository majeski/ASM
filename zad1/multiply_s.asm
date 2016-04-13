        section .text
        extern malloc
        global multiply_s

; (a, x) -> a * x
; 1 < x < 10
multiply_s:
        push ebp
        mov ebp,esp

        push ebx
        push esi
        push edi ; save registers

        mov ebx,[ebp+8] ; get value
        mov edi,[ebp+12] ; get multiplier

        push ebx

        xor ecx,ecx
        mov cx,[ebx] ; get size
        add cx,4 ; size (2 bytes), sign (1 byte), additional place (1 byte)

        push ecx
        call malloc
        pop ecx
        
        add eax,ecx
        dec eax

        mov cx,[ebx]
        add ebx,ecx
        add ebx,2

        mov esi,eax
        mov ebp,ebx

        mov edx,edi

        ; esi last digit in result
        ; ebp last digit in input
        ; ecx size
        ; edx multiplier

        xor dh, dh
loop_s:
        push ecx ; save size
        ; eax, ebx, ecx - free

        ; al - result
        ; bh bl - input 
        ; ch cl - output
        ; dl - multiplier
        ; dh - carry

        mov bh,[ebp]
        mov bl,bh
        and bl,0xF0
        and bh,0x0F
        shr bl,4

        mov al,bh ; get to al
        mul dl ; multiply
        add al,dh ; add carry
        aam ; adjust
        mov dh,ah
        mov cl,al ; save

        mov al,bl ; get to al
        mul dl ; multiply
        add al,dh ; add carry
        aam ; adjust
        mov dh,ah
        mov ch,al ; save

        shl ch,4 ; x0
        or ch,cl ; x0 & 0y
        mov [esi],ch ; save in output
        
        dec esi
        dec ebp

        pop ecx ; load size
        loop loop_s        

        pop ebp ; get input
        mov bx,[ebp] ; get size
        mov ch,[ebp+2] ; get sign

        test dh,dh
        jz skip_resize
        inc bx ; size++
        mov [esi],dh ; save carry
        dec esi

skip_resize:        
        mov [esi],ch
        sub esi,2
        mov [esi],bx

        mov eax,esi

end:
        pop edi
        pop esi
        pop ebx ; restore registers

        pop ebp
        ret

