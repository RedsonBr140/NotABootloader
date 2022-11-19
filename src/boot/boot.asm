[ORG 0x7C00]                           ; The magic BIOS number
[BITS 16]                              ; NASM should generate code to run in 16-bit mode

hlt                                    ; halt the CPU
mov ah, 0h                             ; Set video mode
mov al, 3h                             ; 80x25
int 10h                                ; interrupt 10h
mov si, msg                            ; as lodsb loads SI into al, we load the msg into SI
mov cx, 1                              ; Set delay BIOS wait delay
mov dx, 1                              ; Set delay BIOS wait delay
mov ax, 0x200                          ; Set frequency
call tone                              ; Play sound
mov ax, 0x500                          ; Set frequency again
call tone                              ; Play sound again

call print                             ; Print hello

xor ah,ah                              ; ah = 0
int 16h                                ; Interrupt 16
cmp al, 0x71                           ; Is al equals to q(in ASCII)?
je poweroff                            ; If so, call poweroff
cmp al, 0x72                           ; Is al equals to r(in ASCII)?
je reset                               ; If so, call reset

poweroff:
        mov ah, 53h
        mov al, 07h
        mov bx, 0001h
        mov cx, 03h
        int 15h

reset:
        jmp 0xFFFF:0

print:
        lodsb                          ; Load bytes at SI into al
        cmp al, 0                      ; compare al to 0
        je done                        ; If al equals to 0, then we're finished.
        mov ah, 0Eh                    ; Write character
        xor bh, bh                     ; background = 0
        int 10h                        ; interrupt 10h
        mov ah, 0x86                   ; Wait
        mov al, 0                      ; You ever need to set this unless you get an erratic behavior
        mov cx, 1                      ; Set delay
        int 15h                        ; interrupt 15h
        jmp print                      ; Recursion

done:
        ret                            ; Return to "main"

tone:
        mov bx, ax                     ; 1) Preserve the note value by storing it in BX.
        mov al, 182                    ; 2) Set up the write to the control word register.
        out 43h, al                    ; 2) Perform the write.
        mov ax, bx                     ; 2) Pull back the frequency from BX.
        out 42h, al                    ; 2) Send lower byte of the frequency.
        mov al, AH                     ; 2) Load higher byte of the frequency.
        out 42h, al                    ; 2) Send the higher byte.
        in al, 61h                     ; 3) Read the current keyboard controller status.
        or al, 03h                     ; 3) Turn on 0 and 1 bit, enabling the PC speaker gate and the data transfer.
        out 61h, al                    ; 3) Save the new keyboard controller status.
        mov AH, 86h                    ; 4) Load the BIOS WAIT, int15h function AH=86h.
        int 15h                        ; 4) Immidiately interrupt. The delay is already in CX:DX.
        in al, 61h                     ; 5) Read the current keyboard controller status.
        and al, 0FCh                   ; 5) Zero 0 and 1 bit, simply disabling the gate.
        out 61h, al                    ; 5) Write the new keyboard controller status.
        ret                            ; Epilog: Return.

msg db "Hello, World!", 0      ; msg variable
times 510-($-$$) db 0          ; fill with zeros until we get 510 bytes
dw 0xAA55                      ; 2 bytes BIOS signature
