USE16
org 100h

start:
        test [bx], ch
        cmp [bx], ch
eof: