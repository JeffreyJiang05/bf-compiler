## Brainfuck Language

The syntax of brainfuck:
|Symbol|Purpose|
|:-:|:-:|
|`>`|Increment data pointer|
|`<`|Decrement data pointer|
|`+`|Increment byte|
|`-`|Decrement byte|
|`.`|Output byte to STDOUT|
|`,`|Accept byte from STDIN|
|`[`|If byte is zero, jump to end `]`|
|`]`|If byte is not zero, jump to beginning `[`|

### General implementation

Data pointer will be stored in `BX`.

The compiler will keep track of the position to dump information into using the `DI`
register. 

Instructions such as `STOSB` or `STOSD`. Set the data to be stored at `EAX` register.

### Implementation of `>` and `<`
Can be implemented with a single byte:
```asm
inc bx      ; 43h
dec bx      ; 4Bh
```

### Implementation of `+` and `-`
Can be implemented with two bytes:
```asm
inc byte [bx]  ; FE03
dec byte [bx]  ; FE0B
```

### Implementation of `.`
Can be implemented with six bytes:
```asm
mov ah, 02h     ; B402
mov dl, [bx]    ; 678A13
int 21h         ; CD21
```

### Implementation of `,`
Can be implemented with six bytes:
```asm
mov ah, 01h     ; B401
int 21h         ; CD21
mov [bx], al    ; 678803
```

### Implementation of `[` and `]`
`[` can be implemented with three bytes:
```asm
jmp      1000h           ; E9....
```

`]` can be implemented with six bytes:
```asm
test byte [bx], ch  ; 842F
jnz near 100h       ; 0F85F7FF
```

The procedure of implementing the loop:

When encountering a `[`:
1. Dump the `0xE9` byte.
2. Dump dummy two bytes.
3. Push current instruction position onto the stack. This is the position of the
   loop body.
4. Continue parsing loop

When encountering a `]`:
1. Dump the comparison bytes `0x842F` and the near `jnz` bytes `0x0F85`.
2. Pop the position off of the stack. This is the position of the loop body. This will
   be popped onto `AX` register. 
3. Calculate distance between `EDI` with `EAX`
4. Store this after the `jnz` bytes.
5. Calculate the position of the `jmp` statement via `lea`.
6. Calculate the distance between `EDI` and this new position.
7. Store this after the `jmp` bytes.

## System notes

Little endian. Have to flip constants when dumping.

Memory may already be zeroed out by default. May not need the zero out buffer code. 

### Zero Out Buffer:
Can be done in approximately 8 instructions.
```asm
%define BUFFERSIZE 10h
        xor     ax, ax
        mov     cx, BUFFERSIZE
zeros:
        stosb
        loop    zeros
```

### End of Compiled Program:
In 11 bytes
```
dump_stdout:
        mov     al, '$'         
        stosb                    
        mov     ah, 09h
        mov     dx, eof
        int     21h
        ret
```
Shorter (10 bytes):
```asm
dump_stdout:
        mov     ax, 0924h
        stosb
        mov     dx, eof
        int     21h
        ret
```

May be safer to use STDOUT handle `1` along with the write API function.

## MS DOS API Quick Reference

Call DOS API via `INT 21h`. System call function
identifiers are in the `AH` register. 

|Identifier|Purpose|Arguments|Return|
|:-:|:-:|:-:|:-:|
|`01h`|Read character from STDIN||Character in `AL`|
|`02h`|Write character to STDOUT|Character in `DL`|Character output in `AL`|
|`09h`|Writes `$` terminated string to STDOUT|String in `DX`|`AL=21h`|
|`3Ch`|Creates file|File attributes in `CX`. File name in `DX`|File handle in `AX`|
|`3Dh`|Open file|Access mode in `AL`. File name in `DX`|File handle in `AX`|
|`3Eh`|Close file|File handle in `BX`||
|`3Fh`|Read from file|File handle in `BX`. Bytes to read in `CX`. Buffer in `DX`|Bytes read in `AX`|
|`40h`|Write to file|File handle in `BX`. Bytes to write in `CX`. Buffer in `DX`|Bytes written in `AX`|