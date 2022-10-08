[org 0x7c00]

CODE_SEG    equ     code_descriptor - GDT_Start
DATA_SEG    equ     data_descriptor - GDT_Start
VIDEO_MEMORY    equ 0xb8000
CHAR_OFFSET     equ 0x00002

cli     ; disable all interrupts
lgdt [GDT_Descriptor]

mov eax, cr0
or  eax, 1
mov cr0, eax    ; now we are in 32 bit mode

jmp CODE_SEG:start_protected_mode
jmp $

GDT_Start:
    null_descriptor:
        dd  0
        dd  0
    code_descriptor:
        dw  0xffff  ; limit of our segment
        dw  0       ; 16 bits +
        db  0       ; 8 bits = 24 our base of the segment
        db  0b10011010 ; present, privilege, type and type flags
        db  0b11001111 ; other flags + limit
        db  0       ; last 8 bits of the base
    data_descriptor:
        dw  0xffff
        dw  0
        db  0
        db  0b10010010 ; Same as code descriptor, but last 4 are changed type flags
        db  0b11001111
        db  0
GDT_End:

GDT_Descriptor:
    dw  GDT_End - GDT_Start - 1 ; size of the GDT
    dd  GDT_Start               ; start of the GDT

[bits 32]
start_protected_mode:
    jmp startOS

welcomeMessage:
    db  "Welcome to petOS - n0xne", 0

startOS:
    mov bx, welcomeMessage
    mov ecx, 0
    jmp printMessage

printMessage:
    mov eax, CHAR_OFFSET
    mul ecx
    mov ah, 0x0f
    mov al, [bx]
    cmp al, 0
    je  endMessage
    mov [VIDEO_MEMORY + (ecx * CHAR_OFFSET)], ax
    inc cx
    inc bx
    jmp printMessage

endMessage:

jmp $

times 510-($-$$) db 0
db 0x55, 0xaa
