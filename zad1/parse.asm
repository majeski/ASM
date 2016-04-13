        section .text
        extern malloc
        global parse
        
parse:
        push ebp
        mov ebp,esp

        push ebx
        push esi
        push edi

        mov ebx,[ebp+8]
        ; ebx - current letter

        xor edx,edx
        mov al,[ebx] ; first letter
        cmp al,45 ; check for -
        jnz short lp1

        mov dl,1 ; set minus

lp1: ; while > '9' || < '1'
        mov al,[ebx] ; get letter

        test al,al ; check for 0
        jz short lp1_0end

        cmp al,57
        jg short next_lp1 ; if al > '9'

        cmp al,49
        jl short next_lp1 ; if al < '1'

        jmp short end_lp1 ; end loop

next_lp1: ; go to next letter
        inc ebx
        jmp short lp1

lp1_0end: ; only zeros
        sub ebx,1 ; assume that string beggining is right before 0
        xor dl,dl ; remove minus
end_lp1:

        mov ecx,ebx
        ; ebx - addr of first letter
        ; ecx - addr of current letter
        ; dl - minus

lp2: ; size loop
        mov al,[ecx] ; get letter
        cmp al,0 ; check for 0
        jz short end_lp2
        inc ecx
        jmp short lp2
end_lp2:

        sub ecx,ebx ; size in ecx
        push ecx ; put original size on stack

        add ecx,1
        shr ecx,1 ; ceil(ecx/2)
        add ecx,3 ; place for size (2 bytes) and +/- (1 byte)

        push edx ; save minus
        push ecx ; save malloc arg
        call malloc
        pop ecx ; get malloc arg
        pop edx ; get minus

        sub ecx,3 ; remove size and +/- from value length
        mov [eax],cx ; save size
        mov [eax+2],dl ; save minus

        mov edx,eax
        ; eax - current byte in new string
        ; ebx - original string
        ; ecx - size of original string
        ; edx - new string
        add eax,3

        pop ecx ; get original size
        test ecx,1 ; check parity
        jz short lp3

        mov cl,[ebx] ; first letter
        sub cl,48

        mov [eax],cl

        inc eax
        inc ebx

lp3: ; parse loop
        mov ch,[ebx] ; first letter
        test ch,ch ; check for 0
        jz short end_lp3

        sub ch,48 ; 'x' -> x
        mov cl,[ebx+1] ; second letter
        sub cl,48 ; 'x' -> x

        shl ch,4 
        add ch,cl ; save them in 8bit

        mov [eax],ch ; 8bit with two digits into result string

        inc eax ; next symbol (new string)
        add ebx,2 ; next next symbol (original string)
        jmp lp3

end_lp3:
        mov eax,edx

        pop edi       
        pop esi
        pop ebx
        
        pop ebp
        ret