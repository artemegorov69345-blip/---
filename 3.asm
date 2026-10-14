bits 32

section .data
    filename    db "Сид.txt", 0
    urandom_path db "/dev/urandom", 0
    
    msg_title   db "Rezultaty laboratornoj raboty", 10, 0
    len_title   equ $ - msg_title - 1
    
    msg_even    db "Chetnie chisla", 10, 0
    len_even    equ $ - msg_even - 1
    
    msg_odd     db "Nechetnie chisla", 10, 0
    len_odd     equ $ - msg_odd - 1
    
    msg_ge      db "Chisla >= 50000", 10, 0
    len_ge      equ $ - msg_ge - 1
    
    msg_lt      db "Chisla < 10000", 10, 0
    len_lt      equ $ - msg_lt - 1
    
    newline     db 10, 0
    space_char  db " ", 0

section .bss
    buf         resb 4
    data        resw 512
    
    count_even  resw 1
    count_odd   resw 1
    count_ge50k resw 1
    count_lt10k resw 1
    fd          resd 1
    num_str     resb 12

section .text
    global _start

_start:
    xor eax, eax
    mov [count_even], ax
    mov [count_odd], ax
    mov [count_ge50k], ax
    mov [count_lt10k], ax

main_loop:
    movzx ecx, word [count_even]
    cmp ecx, 127
    jg finish_program
    movzx ecx, word [count_odd]
    cmp ecx, 127
    jg finish_program
    movzx ecx, word [count_ge50k]
    cmp ecx, 127
    jg finish_program
    movzx ecx, word [count_lt10k]
    cmp ecx, 127
    jg finish_program

    call Random
    mov bx, ax

    test bx, 1
    jz .even

    movzx edx, word [count_odd]
    lea edi, [data + 256]
    mov [edi + edx*2], bx
    inc word [count_odd]
    jmp .check_ranges

.even:
    movzx edx, word [count_even]
    lea edi, [data]
    mov [edi + edx*2], bx
    inc word [count_even]

.check_ranges:
    cmp bx, 50000
    jb .lt_10k     
    movzx edx, word [count_ge50k]
    lea edi, [data + 512]
    mov [edi + edx*2], bx
    inc word [count_ge50k]

.lt_10k:
    cmp bx, 10000
    jae main_loop 
    movzx edx, word [count_lt10k]
    lea edi, [data + 768]
    mov [edi + edx*2], bx
    inc word [count_lt10k]
    jmp main_loop

Random:
    push ebx
    push ecx
    push edx
    
    mov eax, 5
    mov ebx, urandom_path
    xor ecx, ecx
    int 0x80
    
    mov ebx, eax
    mov eax, 3
    mov ecx, buf
    mov edx, 2
    int 0x80
    
    mov eax, 6
    int 0x80
    
    mov ax, [buf]
    
    pop edx
    pop ecx
    pop ebx
    ret

write_string:
    push eax
    mov eax, 4
    int 0x80
    pop eax
    ret

finish_program:
    mov eax, 8
    mov ebx, filename
    mov ecx, 0666o
    int 0x80
    mov [fd], eax

    mov ebx, [fd]
    
    mov ecx, msg_title
    mov edx, len_title
    call write_string

    mov ecx, msg_even
    mov edx, len_even
    call write_string
    lea esi, [data]
    movzx ecx, word [count_even]
    mov ebx, [fd]
    call dump_array

    mov ecx, msg_odd
    mov edx, len_odd
    call write_string
    lea esi, [data + 256]
    movzx ecx, word [count_odd]
    mov ebx, [fd]
    call dump_array

    mov ecx, msg_ge
    mov edx, len_ge
    call write_string
    lea esi, [data + 512]
    movzx ecx, word [count_ge50k]
    mov ebx, [fd]
    call dump_array

    mov ecx, msg_lt
    mov edx, len_lt
    call write_string
    lea esi, [data + 768]
    movzx ecx, word [count_lt10k]
    mov ebx, [fd]
    call dump_array

    ; закрываем файл
    mov eax, 6
    mov ebx, [fd]
    int 0x80

    ; вывод на экран
    mov ebx, 1
    
    mov ecx, msg_title
    mov edx, len_title
    call write_string

    mov ecx, msg_even
    mov edx, len_even
    call write_string
    lea esi, [data]
    movzx ecx, word [count_even]
    mov ebx, 1
    call dump_array

    mov ecx, msg_odd
    mov edx, len_odd
    call write_string
    lea esi, [data + 256]
    movzx ecx, word [count_odd]
    mov ebx, 1
    call dump_array

    mov ecx, msg_ge
    mov edx, len_ge
    call write_string
    lea esi, [data + 512]
    movzx ecx, word [count_ge50k]
    mov ebx, 1
    call dump_array

    mov ecx, msg_lt
    mov edx, len_lt
    call write_string
    lea esi, [data + 768]
    movzx ecx, word [count_lt10k]
    mov ebx, 1
    call dump_array

    mov eax, 1
    xor ebx, ebx
    int 0x80

dump_array:
    pushad

.loop_start:
    test ecx, ecx
    jz .done
    push ecx
    push esi
    
    mov ax, [esi]
    call int_to_str
    
    mov eax, 4
    int 0x80
    
    mov eax, 4
    mov ecx, space_char
    mov edx, 1
    int 0x80
    
    pop esi
    pop ecx
    add esi, 2
    dec ecx
    jmp .loop_start

.done:
    mov eax, 4
    mov ecx, newline
    mov edx, 1
    int 0x80
    popad
    ret

int_to_str:
    push edi
    mov edi, num_str
    add edi, 11
    mov byte [edi], 0
    dec edi
    
    movzx eax, ax
    test eax, eax
    jnz .convert_loop
    
    mov byte [edi], '0'
    dec edi
    jmp .done_conv

.convert_loop:
    xor edx, edx
    mov ecx, 10
    div ecx
    add dl, '0'
    mov [edi], dl
    dec edi
    test eax, eax
    jnz .convert_loop

.done_conv:
    inc edi
    mov ecx, edi
    mov edx, num_str
    add edx, 12
    sub edx, ecx
    pop edi
    ret
