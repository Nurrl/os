%define ENDL 0x0D, 0x0A

puts:
    lodsb               ; loads next character in al
    or al, al           ; verify if next character is null
    jz .done

    mov ah, 0x0E        ; call bios interrupt
    mov bh, 0           ; set page number to 0
    int 0x10

    jmp puts
.done:
    ret
