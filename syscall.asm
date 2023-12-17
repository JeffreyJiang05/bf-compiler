
org 100h

_start:
        mov     AH, 3Ch
        mov     BH, 40h
        mov     DX, fn
        xor     CX, CX
        int     21h

        xchg    BX, AX
        mov     CX, fn - txt
        mov     DX, txt
        int     21h

        mov     AH, 3Eh
        int     21h

        mov     eax, 100h

        ret
txt:
        db      "Test test test"
fn:     
        db      "test.txt",0