[BITS 32]
[SECTION .text]

extern _printf
global _x64_cpu_check

;=========================================================================
; More details: https://www.felixcloutier.com/x86/cpuid
;-------------------------------------------------------------------------

_x64_cpu_check:
    push entry_msg
    call _printf
    add esp, 4

.cpu_check:

;=========================================================================
; EAX - Maximum Input Value for Extended Function CPUID Information
;-------------------------------------------------------------------------

    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000008
    jb .old_cpu

    push eax
    push function_num
    call _printf
    add esp, 8

;=========================================================================
; EAX - Extended Processor Signature and Feature Bits
;      Bit 29: Intel® 64 Architecture available if 1
;-------------------------------------------------------------------------

    mov eax, 0x80000001
    cpuid
    bt edx, 29
    jnc .not_support_x64

    push support_x64_msg
    call _printf
    add esp, 4

;=========================================================================
; Processor Brand String
;-------------------------------------------------------------------------

    mov eax, 0x80000002
    cpuid
    mov [cpu_info + 4 * 0], eax
    mov [cpu_info + 4 * 1], ebx
    mov [cpu_info + 4 * 2], ecx
    mov [cpu_info + 4 * 3], edx

    mov eax, 0x80000003
    cpuid
    mov [cpu_info + 4 * 4], eax
    mov [cpu_info + 4 * 5], ebx
    mov [cpu_info + 4 * 6], ecx
    mov [cpu_info + 4 * 7], edx

    mov eax, 0x80000004
    cpuid
    mov [cpu_info + 4 * 8], eax
    mov [cpu_info + 4 * 9], ebx
    mov [cpu_info + 4 * 10], ecx
    mov [cpu_info + 4 * 11], edx

    push cpu_info_title
    call _printf
    add esp, 4

    push cpu_info_end
    call _printf
    add esp, 4

;=========================================================================
; EAX - Linear/Physical Address size
;     Bits 07-00: Physical Address Bits
;     Bits 15-08: Linear Address Bits
;     Bits 31-16: Reserved = 0
;-------------------------------------------------------------------------

    mov eax, 0x80000008
    cpuid
    mov [phy_addr_size], al
    mov [vir_addr_size], ah

    mov eax, [phy_addr_size]
    push eax
    push phy_addr_size_format
    call _printf
    add esp, 8

    mov eax, [vir_addr_size]
    push eax
    push vir_addr_size_format
    call _printf
    add esp, 8
    jmp .end

.not_support_x64:
    push not_support_x64_msg
    call _printf
    add esp, 4
    jmp .end

.old_cpu:
    push old_cpu_msg
    call _printf
    add esp, 4

.end:
    ret

;=========================================================================
; String definition
;-------------------------------------------------------------------------

[SECTION .rodata]
entry_msg: 
    db "start detecting CPU", 10, 0 
old_cpu_msg: 
    db "old CPU, end..", 10, 0
function_num: 
    db "cpu max function number: 0x%x", 10, 0

support_x64_msg: 
    db "support x64, continue..", 10, 0
not_support_x64_msg: 
    db "no support x64, end..", 10, 0

cpu_info_title: 
    db "cpu info: "
cpu_info: 
    times 48 db 0
cpu_info_end: 
    db 10, 0

phy_addr_size: 
    dd 0
vir_addr_size: 
    dd 0
phy_addr_size_format: 
    db "physical address size : %d bits", 10, 0
vir_addr_size_format: 
    db "virtual address size : %d bits", 10, 0