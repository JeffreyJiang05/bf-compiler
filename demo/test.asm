USE16
org 100h

start:
        ; mov     eax, 0x850F2F38                 ; Load TEST and load JNZ.
        ; stosd                                   ; Write instructions to DI
        ; lea     si, [di - 6]                    ; 6 = 4 opcode bytes + rel16
        ; pop     bp                              ; Pop JMP rel16 to be resolved in closing bracket
        ; sub     si, bp                          ; SI - BP yields the size of the loop body
        ; mov     [bp], si                        ; Finally, resolve undetermined JMP rel16.
        ; sub     bp, di                          ; BP - DI yields distance between JMP and JNZ.
        ; mov     ax, bp                          ; Moves BP to AX to be stored.
        ; stosw                                   ; Store displacement for JNZ.

        mov     eax, 0x850F2F38                 ; Load TEST and load JNZ.
        stosd                                   ; Write instructions to DI
        lea     bp, [di - 6]                    ; 6 = 4 opcode bytes + rel16
        pop     si                              ; Pop JMP rel16 to be resolved in closing bracket
        sub     bp, si                          ; SI - BP yields the size of the loop body
        mov     [si], bp                        ; Finally, resolve undetermined JMP rel16.
        sub     si, di                          ; BP - DI yields distance between JMP and JNZ.
        mov     ax, si                          ; Moves BP to AX to be stored.
        stosw                                   ; Store displacement for JNZ.
eof: