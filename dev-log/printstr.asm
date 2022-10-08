[org 0x7c00]

mov ah, 0x0e
mov bx, ourString

printString:
    mov al, [bx]
    cmp al, 0
    je  endString
    int 0x10
    inc bx
    jmp printString

endString:
    jmp $

ourString:
    db "Hello! momo", 0

times 510-($-$$) db 0
db 0x55, 0xaa
