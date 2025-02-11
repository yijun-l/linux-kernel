[BITS 32]
[SECTION .rodata]
entry_msg: db "start detecting CPU", 10, 0 
old_cpu_msg: db "old CPU, end..", 10, 0
support_x64_msg: db "support x64, continue..", 10, 0
no_support_x64_msg: db "no support x64, end..", 10, 0
function_num: db "cpu max function number: 0x%x", 10, 0

[SECTION .text]

extern _printf

global _x64_cpu_check
_x64_cpu_check:
    push entry_msg
    call _printf
    add esp, 4

.cpu_check
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000008
    jb .old_cpu

    push eax
    push function_num
    call _printf
    add esp, 8

    mov eax, 0x80000001
    cpuid
    bt edx, 29
    jnc .no_support_x64

    push support_x64_msg
    call _printf
    add esp, 4

    jmp .end

.no_support_x64:
    push no_support_x64_msg
    call _printf
    add esp, 4
    jmp .end

.old_cpu:
    push old_cpu_msg
    call _printf
    add esp, 4

.end:
    jmp $