%define TEXT 100h
%define BUFFERSIZE 10h

org TEXT

_start:
        mov     edi, eof
        mov     ax, 4b43h
        stosw

        xor     ax, ax
        mov     cx, BUFFERSIZE
zeros:
        stosb
        loop    zeros

dump:
        ; lea     cx, [di - eof]
        mov     ah, 40h
        xor     bx, bx
        inc     bx
        mov     dx, eof 
        lea     cx, [word di - eof]
        int     21h
        ret

dump_stdout:
        mov     ax, 0924h
        stosb
        mov     dx, eof
        int     21h
        ret
eof:
