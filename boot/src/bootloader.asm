
[BITS 16]

[org 0x7c00]
jmp boot_start

%include "src/print_16.asm"
%include "src/load_kernel.asm"
%include "src/gd_table.asm"
%include "src/switch_32.asm"
%include "src/print_32.asm"

[BITS 16]
boot_start:
	mov bp, 0x8000 ; set the stack
    mov sp, bp
	
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
	
	call load_kernel
	
	mov si, KERNEL_LOADED
	call print_str_16
	call print_nl_16

	
	mov si, SWITCH_32
	call print_str_16
	call print_nl_16

	call switch_to_pm
	
	jmp boot_end ; wont run
	
	
[BITS 32]
pm_mode_start:
	mov esi, IN_32_MODE
	call print_str_32
	call print_nl_32
	
	;call KERNAL_OFFSET
	
	jmp boot_end
	

IN_16_MODE: db 'In 16-bit mode', 0
IN_32_MODE: db 'In 32-bit mode', 0
;PRESS_ENTER: db 'Press enter to continue booting', 0
;ENTER_PRESSED: db 'Enter pressed, booting into OS-2...', 0
;WELCOME: db 'Welcome to OS-2', 0
KERNEL_LOADED: db 'Kernel loaded sucessfully', 0
SWITCH_32: db 'Switching to 32-bit Mode', 0
	

boot_end:
	jmp $

times 510-($-$$) db 0
dw 0xaa55
