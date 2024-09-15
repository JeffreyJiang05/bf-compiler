USE16
org 100h

start:
        xchg    si, bp
        mov     di, 100h

        inc     ch
        push    cx
        pop     di
eof: