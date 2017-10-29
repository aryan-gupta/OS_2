[bits 32] 

VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f ; the color byte for each character

print_str_32:
	pusha
	mov edx, VIDEO_MEMORY
  .ps_repeat:
	lodsb
	mov ah, WHITE_ON_BLACK
	test al, al ; check if end of string
	je .ps_ret
	mov [edx], ax ; store character + attribute in video memory
	add edx, 2 ; next video memory position
	jmp .ps_repeat
  .ps_ret:
	popa
	ret
	
print_nl_32:
	pusha
	mov edx, VIDEO_MEMORY
	mov ax, 0x0f0a
	mov [edx], ax
	add edx, 2
	mov ax, 0x0f0d
	mov [edx], ax
	add edx, 2
	