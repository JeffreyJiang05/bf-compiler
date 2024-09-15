;|--------------------------------------------------------------------------------------|;
;| TEENSY TINY BRAINFUCK COMPILER                                                       |;
;| VERSION 4                                                                            |;
;| xxx bytes                                                                            |;
;| Author: Jeffrey Jiang                                                                |;
;| Target: MS DOS on 80386+                                                             |;
;| Heavily inspired by                                                                  |;
;| https://www.muppetlabs.com/~breadbox/software/tiny/useless.html                      |;
;| USAGE                                                                                |;
;| bf.exe < input.bf > prog.exe                                                         |;
;|--------------------------------------------------------------------------------------|;

; BASIC MACROS
%define TEXT 100h                               ; Tells DOS loads instructions to 0x100
%define CELLS 8000h                             ; Number of cells. 32 KiB

; DOS API MACROS
%define SYS_CALL 21h                            ; System call
%define READ_CHAR 01h
%define WRITE_CHAR 02h
%define READ_FILE 3Fh

use16                                           
org     TEXT

; Beginning of the compiler.
_start:
        ; BX set automatically to 0.
        mov     di, writable_buffer             ; Set to point to writable program buffer.
get_char:
        mov     ah, READ_FILE                   ; Retrieve char from STDIN and store in AL.
        mov     dx, program_buffer + 1          ; Set buffer.
        mov     cl, 1                           ; CX = 1. Bytes to read.
        int     SYS_CALL
        test    ax, ax                          ; Set ZF for AX.
        jz      complete_compilation;           ; If not more characters, jump to finish the compilation.
        mov     al, [program_buffer + 1]        ; AL holds input character.

; Dispatches based on character of input
; Perhaps can be looped. Thus, eliminating extra bytes.
switch:
        mov     si, inc_byte_data               ; Set SI to inc_byte_data/dec_byte_data. Points to data to be copied to program buffer.
        inc     cx                              ; CX = 2. Used for looping twice.
loop_twice:                                     ; Loops twice. First checks for `+`, `,`, `<`. Then, `-`, `.`, `>`.
        cmp     al, '+'
        je      dump_two                        ; Dump the two bytes for `+`/`-`.
        
        inc     si
        inc     si                              ; Move SI forward two bytes to stdin_byte_data/stdout_byte_data.
        cmp     al, ','
        je      dump_six                        ; Dump the six bytes for `,`/`.`.

        add     si, 6                           ; Move SI forward six bytes to dec_data_pointer/inc_data_pointer.
        cmp     al, '<'              
        je      dump_one                        ; Dump the one byte for `<`/'>'.

        inc     si                              ; Move SI forward one byte to dec_byte_data/open_bracket_data

        dec     ax
        dec     ax                              ; Decrease AL by two. Now `-` -> `+`; `.` -> `,`; `>` -> `<`.

        loop    loop_twice

; Processing the brackets are more complex. Handled separately.
        cmp     al, '[' - 4
        je      open_bracket                    ; Process for `[`.

        inc     si                              ; Move SI forward 
        cmp     al, ']' - 4
        je      close_bracket                   ; Process for `]`.
relay:
        jmp     get_char

; Relies on SI to be set correctly. Copies the appropriate number of byte from SI to DI.
dump_six:
        movsd
dump_two:
        movsb
dump_one:
        movsb
        jmp     relay                           ; Jump back to getting characters.

open_bracket:
        movsb                                   ; Write JMP opcode to DI.
        push    di                              ; Push JMP rel16 to be resolved by closing bracket.
        jmp     dump_two                        ; Write extra two random bytes to DI.

close_bracket:
        movsd                                   ; Write instructions to DI.   
        lea     bp, [di - 6]                    ; 6 = 4 opcode bytes + rel16.
        pop     si                              ; Pop JMP rel16 to be resolved in closing bracket.
        sub     bp, si                          ; BP - SI yields the size of the loop body.
        mov     [si], bp                        ; Finally, resolve undetermined JMP rel16.
        sub     si, di                          ; SI - DI yields distance between JMP and JNZ.
        mov     ax, si                          ; Moves SI to AX to be stored.
        stosw                                   ; Store displacement for JNZ.
        jmp     relay

complete_compilation:
        mov     al, 0xC3                        ; Load RET opcode.
        stosb                                   ; Write RET to DI.
        lea     cx, [di - EOF]                  ; Set CX to length of the compiled program excluding data for cells. 
        inc     ch                              ; Correct location of cell buffer in compiled program. CX += 100h.
        mov     [program_buffer + 1], cx
zero_buffer:                                    ; Initializes the cells for the compiled program. Sets all to 0x00.
        xor     ax, ax                          ; Set AX to 0.
        mov     cx, CELLS                       ; Set CX to the number of cells for compiled program.
zeros:
        stosb                                   ; Store AX into DI
        loop    zeros                           ; Dumps AX into DI for a total of CELLS times.

; Dumps the program buffer to STDOUT. Then, terminates program. 
dump_buffer:
        mov     ax, 0924h                       ; AH = 09h. AL = '$'.
        stosb                                   ; Dump '$' at the end of the buffer.
        mov     dx, program_buffer              ; Buffer
        int     SYS_CALL
; To terminate the compiled program. Use a RET.
compiler_end:
        ret                                     ; terminate program. Stack should be 0.

; Instruction used as data to be dumped into compiled program.
; The following instruction will never be executed by the compiler.
inc_byte_data:                                  ; Character `+`
        inc     byte [bx]                       ; 2 bytes

stdin_byte_data:                                ; Character `,`
        mov     ah, READ_CHAR                   ; 2 bytes
        int     SYS_CALL                        ; 2 bytes
        mov     [bx], al                        ; 2 bytes

dec_data_pointer:                               ; Character `<`
        dec     bx                              ; 1 byte

dec_byte_data:                                  ; Character `-`
        dec     byte [bx]                       ; 2 bytes

stdout_byte_data:                               ; Character `.`
        mov     ah, WRITE_CHAR                  ; 2 bytes
        mov     dl, [bx]                        ; 2 bytes
        int     SYS_CALL                        ; 2 bytes

inc_dec_pointer:                                ; Character `>`
        inc     bx                              ; 1 byte

; Data for the brackets characters are handled separately. See open_bracket and close_bracket.

open_bracket_data:
        db      0xE9                            ; Load JMP opcode.

close_bracket_data:
        dd      0x850F2F38                      ; Load CMP and load JNZ.
        
EOF:                                            ; End of compiler program.
; The compiled file is stored at the end of the compiler program.
program_buffer:
        mov     bx, 0xFFFF                      ; 0xFFFF to be replaced by the size of the compiled program.
                                                ; Buffer to store character from STDIN in program_buffer + 1
writable_buffer:   