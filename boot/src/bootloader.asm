
[BITS 16]

[org 0x7c00]
jmp boot_start

%include "src/print_16.asm"

boot_start:
	call clr_scr_16
	call hide_cursor_16
	call reset_cursor_16
	
	
	mov si, IN_16_MODE
	call print_str_16
	call print_nl_16
	
	mov si, WELCOME
	call print_str_16
	call print_nl_16
	
	mov si, PRESS_ENTER
	call print_str_16
	call print_nl_16
	
	mov bh, 0x1c ; http://www.fountainware.com/EXPL/bios_key_codes.htm
	call wait_for_key
	
	mov si, ENTER_PRESSED
	call print_str_16
	call print_nl_16
	
	jmp boot_end
	

IN_16_MODE: db 'In 16-bit mode', 0
IN_32_MODE: db 'In 32-bit mode', 0
PRESS_ENTER: db 'Press enter to continue booting', 0
ENTER_PRESSED: db 'Enter pressed, booting into OS-2...', 0
WELCOME: db 'Welcome to OS-2', 0
	
boot_end:
	jmp $
	times 510-($-$$) db 0
	dw 0xaa55
	