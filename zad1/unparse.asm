        section .text
        extern malloc
        global unparse

unparse:
        push ebp
        mov ebp,esp

        push ebx
        push esi
        push edi

        mov ebx,[ebp+8]
        xor ecx,ecx
        mov cx,[ebx]
        shl cx,1
        ; ebx - arg
        ; cx - size

        mov al,[ebx+2] ; check for -
        mov ah,[ebx+3] ; check for 0
        cmp al,45
        jne short skip1
        test ah,ah
        jz short skip1
        inc cx

skip1:
        mov al,[ebx+3] ; check for 0x
        test al,0xF0 
        jnz short skip2
        dec cx

skip2:
        inc cx ; byte for 0 at the end

        push ecx
        call malloc
        add esp,4 ; drop arg

        xor edx,edx
        mov dx,[ebx]
        ; eax - new string
        ; ebx - original string
        ; dx - original string size
        mov edi,eax ; save new string

        mov cl,[ebx+2]
        mov ch,[ebx+3]
        add ebx,3 ; first letter
        test cl,cl ; check for -
        jz short skip3
        test ch,ch ; check for 0
        jz short skip3
        mov byte [eax],45 ; insert -
        inc eax ; next

skip3:
        mov cl,[ebx]
        test cl,0xF0 ; check for 0x
        jnz short while1
        and cl,0x0F
        add cl,48
        mov [eax],cl
        inc eax
        inc ebx
        dec dx

while1:
        test dx,dx
        jz short end1

        mov cl,[ebx] ; get xy
        inc ebx

        mov ch,cl
        shr cl,4 ; get x
        and ch,0x0F ; get y

        add ch,48 ; y -> 'y'
        add cl,48 ; x -> 'x'

        mov [eax],cl
        inc eax
        mov [eax],ch
        inc eax

        dec dx
        jmp short while1

end1:
        mov BYTE [eax],0

        mov eax,edi ; get new string

        pop edi       
        pop esi
        pop ebx

        pop ebp
        ret