[ORG  0x500]
[BITS 16]

_start:
;=========================================================================
; the entry of 0x500
;-------------------------------------------------------------------------

    mov si, msg
    call print
    xchg bx, bx		        ; Magic Breakpoint
    sti                     ; set IF to 1 in case Bochs stuck 
    jmp stuck_loop

;=========================================================================
; Halt the CPU
;-------------------------------------------------------------------------

stuck_loop:
    hlt
    jmp stuck_loop

;=========================================================================
; print - print string to display
; Input:
;       SI - string address
; Output:
;       none
;-------------------------------------------------------------------------

print:
    mov ah, 0x0e            ; INT 0x10 mode - Teletype output
    mov bh, 0               ; BH = Page Number
    mov bl, 1               ; BL = Color

.loop:
    mov al, [si]            ; AL = Character
    cmp al, 0
    jz .done
    int 0x10                ; IVT 0x10 - Video Services

    inc si
    jmp .loop

.done:
    ret

;=========================================================================
; String definition
;-------------------------------------------------------------------------

msg:
    db "Jumped to 0x500", 0xa, 0xd, 0
