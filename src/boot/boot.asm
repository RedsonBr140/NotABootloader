[ORG 0x7C00]                   ; The magic BIOS number
[BITS 16]                      ; NASM should generate code to run in 16-bit mode

hlt                            ; halt the CPU
mov ah, 0h                     ; Set video mode
mov al, 3h                     ; 80x25
int 10h                        ; interrupt 10h
mov si, msg                    ; as lodsb loads SI into AL, we load the msg into SI
call print                     ; Print hello

print:
        lodsb                          ; Load bytes at SI into AL
        cmp al, 0                      ; compare al to 0
        je done                        ; If AL equals to 0, then we're finished.
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

msg db "Hello, World!", 0      ; msg variable
times 510-($-$$) db 0          ; fill with zeros until we get 510 bytes
dw 0xAA55                      ; 2 bytes BIOS signature
