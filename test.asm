USE16
org 100h

start:

jmp near cond
loop_body:
add eax,[ebx]
add eax,[ebx]
add eax,[ebx]
add eax,[ebx]
cond:
test [bx],ch
jnz near loop_body