
; Stage 1 bootloader
; This stage only outputs minimal text and loads the 2nd stage
; This uses FAT32 to do this
[BITS 16]
[org 0x7c00] ; we are going to have to set the segments too

jmp stage0_start

%include "src/print_16.asm"
%include "src/load_kernel.asm"
%include "src/gd_table.asm"
%include "src/switch_32.asm"
%include "src/print_32.asm"

[BITS 16]
stage0_start:
	cli ; stop all interupts
	
	mov ax, 0x0 ; set segment registors
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	mov bp, 0x8000 ; set the stack
    mov sp, bp
	
	mov [BootDrive], dl ; move the boot drive (suplied by out BIOS)
	
	sti ; start inturupts again
	
	call clr_scr_16
	call hide_cursor_16
	call reset_cursor_16
	
	mov si, ENTRY_MESSAGE
	call print_str_16
	call print_nl_16	
	
	
	mov si, LOAD_S2_MESSAGE
	call print_str_16
	call print_nl_16
	
	; call load_stage2
	
	mov si, START_S2_MESSAGE
	call print_str_16
	call print_nl_16
	

	call load_kernel
	
	mov si, KERNEL_LOADED
	call print_str_16
	call print_nl_16

	
boot_error:
	mov si, BOOT_ERROR
	call print_str_16
	jmp boot_end
	

IN_16_MODE: db 'In 16-bit mode', 0
IN_32_MODE: db 'In 32-bit mode', 0
;PRESS_ENTER: db 'Press enter to continue booting', 0
;ENTER_PRESSED: db 'Enter pressed, booting into OS-2...', 0
;WELCOME: db 'Welcome to OS-2', 0
KERNEL_LOADED: db 'Kernel loaded sucessfully', 0
SWITCH_32: db 'Switching to 32-bit Mode', 0
	

boot_end:
	cli
	hlt

times 446-($-$$) db 0 ; we need space for the partion

db 0x80
db 0x38   ; 0th head
dw 0x0029 ; to test if we can set this 0
db 0x0c   ; This is a FAT32 drive
db 0xfe
dw 0xf83f
dd 0x0df0
dd 0x3d3210

times 512 - ($-$$) db 0 ;
dw 0xaa55 ; boot signature
	
