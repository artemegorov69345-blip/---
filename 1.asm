section .text
	global _start
_start:
mov eax, 0x11223344
mov ebx, 0x11445523
mov ecx, 0x13541124

xchg ecx, eax


mov edx, eax
mov eax, ebx
mov ebx, edx

lea edx, [eax]
mov eax, ebx
mov ebx, ecx 

push eax
push ebx
pop eax
pop edx


mov ax, 0x3344
mov bx, 0x5523
mov cx, 0x1124

xchg cx, ax

mov dx, ax
mov ax, bx
mov bx, dx

lea dx, [bx]
mov ax, bx
mov bx, cx

push ax
push bx
pop ax
pop dx


mov al, 0x44
mov bl, 0x23
mov cl, 0x24

xchg cl, al

mov dl, al 
mov al, bl 
mov bl, dl 

mov bh, 0x00
lea dx, [bx]
mov al, bl
mov bl, cl 



int 0x80