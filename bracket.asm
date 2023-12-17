%define DEBUG
%define TEXT 100h

org TEXT

main:
        mov     edi, eof
bracketstart:
        mov     al, 0xE9        ; Load JMP opcode
        stosb                   ; Write JMP opcode
        stosw                   ; Fill diplacement two bytes
        push    di              ; Push loop boddy address
filler:
        mov     eax, 0x03036766
        stosd
        stosd
        stosd
        stosd
bracketend:
        mov     eax, 0x850F2F84
        mov     cx, di                  ; BP points to test instruction
        pop     bp                      ; Retrieve loop body address in BP
        sub     cx, bp
        mov     [bp], cx                ; [BP] now stores position for DI
        stosd
        neg     cx
        sub     cx, 6
        mov     ax, cx
        stosw
%if 0
dump:
        mov     ax, 0924h
        stosb
        mov     dx, eof
        int     21h
%endif
        ret

%ifdef DEBUG
dump:
        mov     ah, 02h
        mov     dl, al
        int     21h
        ret
%endif

eof: