[BITS 16]
global _start

_start:
    xchg bx, bx		    ; Magic Breakpoint


times 510 - ($ - $$) db 0
db 0x55, 0xaa		    ; Boot Sector Signature