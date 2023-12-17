%define TEXT 100h

org TEXT

main:
        mov     edi, eof
        mov     ax, 0x9090
        stosw
        stosw
bracketstart:
        mov     al, 0xE9        ; Load JMP opcode
        stosb                   ; Write JMP opcode
        push    di              ; Push address of unknown displacement
        stosw                   ; Fill diplacement two bytes
filler:
        mov     eax, 0x03036766
        stosd
        stosd
        stosd
        stosd
        stosd
        stosd
        mov     ax, 0x6640
        stosw
        stosb
bracketend:
        ; 22 bytes
        mov     eax, 0x850F2F84         ; Load instructions
        stosd                           ; Write instructions
        lea     si, [di - 6]            ; 6 = 4 opcode bytes + 2 bytes of unknown displacement after jmp
        pop     bp                      ; retrieve address of unknown jmp displacement in BP
        sub     si, bp                  ; si - bp yields distance between of loop body
        mov     [bp], si                ; store in bp  
        sub     bp, di                  ; bp - di yields the distance between jmp statements
        mov     ax, bp                  ; stores bp for write
        stosw                           ; store displacement after jnz

%ifndef DEBUG
dump:
        mov     ax, 0924h
        stosb
        mov     dx, eof
        int     21h
%endif
        ret

%ifdef DEBUG
printchar:
        mov     ah, 02h
        int     21h
        ret
%endif

eof: