[ORG 0x7c00]

[BITS 16]
global _start

_start:
    xchg bx, bx		    ; Magic Breakpoint

;=========================================================================
; Clear the screen
;-------------------------------------------------------------------------

    mov ah, 0x00	    ; Set Video Mode
    mov al, 0x03	    ; Text Mode, 80*25
    int 0x10		    ; IVT 0x10 - Video Services

;=========================================================================
; Print string to screen
;-------------------------------------------------------------------------

    mov si, display_msg
    call print
    jmp stuck_loop

;=========================================================================
; print - print string to display
; Input:
;	SI - string address
; Output:
;	none
;-------------------------------------------------------------------------

print:
    mov ah, 0x0e	    ; INT 0x10 mode - Teletype output
    mov bh, 0		    ; BH = Page Number
    mov bl, 1		    ; BL = Color

.loop:
    mov al, [si]	    ; AL = Character
    cmp al, 0
    jz .done
    int 0x10		    ; IVT 0x10 - Video Services

    inc si
    jmp .loop

.done:
    ret

;=========================================================================
; Halt the CPU
;-------------------------------------------------------------------------

stuck_loop:
    hlt
    jmp stuck_loop
    
;=========================================================================
; String definition
;-------------------------------------------------------------------------

display_msg:
    db "Hello World!", 0xa, 0xd, 0

;=========================================================================
; padding
;-------------------------------------------------------------------------

times 510 - ($ - $$) db 0
db 0x55, 0xaa		    ; Boot Sector Signature