; Minimal Bootloader handoff (Multiboot2)
section .multiboot
header_start:
    dd 0xe85250d6                ; magic number
    dd 0                         ; protected mode i386
    dd header_end - header_start ; header length
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start)) ; checksum
    dd 0                         ; end tag
header_end:

section .text
global _start
extern kernel_main

_start:
    ; Setup stack
    mov esp, stack_top
    call kernel_main
    hlt

section .bss
stack_bottom:
    resb 16384 ; 16KB stack
stack_top:
