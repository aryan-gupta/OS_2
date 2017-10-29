[org 0x7c00]
jmp boot_start

%include "src/print_16.asm"

boot_start:
	mov si, IN_16_MODE
	call print_str_16
	
	call print_nl_16
	
	mov si, WELCOME
	call print_str_16
	
	call print_nl_16
	
	jmp boot_end
	

IN_16_MODE: db 'In 16-bit mode', 0
IN_32_MODE: db 'In 32-bit mode', 0
WELCOME: db 'Welcome to OS-2', 0
	
boot_end:
	jmp $
	times 510-($-$$) db 0
	dw 0xaa55
	