USE16
org 100h

start:
        mov     ah, 40h
        xor     bx, bx
        inc     bx
        mov     dx, eof 
        lea     cx, [word di - eof]
        ; sub     di, dx
        ; mov     cx, di
        int     21h
        ret
eof: