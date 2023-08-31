org 0x3e ; account for the FAT12 header
bits 16

jmp start

%include "fat12.s"
%include "puts.s"

sectorsize equ 512
bootloader equ 0x7c00
stacksize equ 256

start:
    ; get memory size in KiB
    int 0x12
    shl ax, 6 ; and convert it to 16-byte words

    ; reserve space for bootloader
    sub ax, sectorsize / 16
    mov es, ax

    ; reserve space for stack and setup stack pointer
    cli
    sub ax, stacksize
    mov ss, ax
    mov sp, stacksize
    sti

    ; relocate bootloader at the end of the available memory
               ; destination segment set earlier in `es`
    xor di, di ; destination address
    mov ds, di ; source segment
    mov si, bootloader ; source address

    mov cx, sectorsize / 4 ; dword count

    cld
    rep movsd

    ; setup segment registers
    push es
    pop ds

    ; jump to relocated bootloader
    push es
    push boot
    retf

bootfile db "boot    bin", 0
boot:
    ; here goes the code

    ; halt
    jmp halt

haltmsg db ENDL, "-- System halted, bye !", ENDL, 0
halt:
    mov si, haltmsg
    call puts

    cli ; disable interrupts, this way CPU can't get out of "halt" state
    hlt
