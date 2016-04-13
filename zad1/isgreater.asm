        section .text
        global isgreater

; (a, b) -> |a| > |b| ? 1 : 0
isgreater:
        push ebp
        mov ebp,esp

        push ebx
        push esi
        push edi ; save registers

        mov eax,[ebp+8]
        mov ebx,[ebp+12]

        xor ecx,ecx
        mov cx,[eax] ; get size 
        mov dx,[ebx] ; get size 2

        cmp cx,dx ; 
        ja short end1 ; longer value
        jb short end0 ; shorter value

        add eax,3
        add ebx,3 ; get first digit

loop_s:
        mov dl,[eax]
        mov dh,[ebx]
        cmp dl,dh
        ja short end1
        jb short end0
        inc eax
        inc ebx
        loop loop_s

end0:
        xor eax,eax
        jmp short end

end1:
        mov eax,1

end:
        pop edi
        pop esi
        pop ebx ; restore registers

        pop ebp
        ret

