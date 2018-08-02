
; Stage 1 bootloader
; This stage only outputs minimal text and loads the 2nd stage
; This uses FAT32 to do this
[BITS 16]
[org 0x7c00] ; we are going to have to set the segments too

jmp stage0_start

%include "src/print_16.asm"
%include "src/load_stage2.asm"

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
	
	call stage2_start_addr
	
	jmp boot_end ; wont run	
	
boot_error:
	mov si, BOOT_ERROR
	call print_str_16
	jmp boot_end
	

; conststant data
ENTRY_MESSAGE    db 'Welcome to OS 2', 0
LOAD_S2_MESSAGE  db 'Loading stage 2', 0
START_S2_MESSAGE db 'Starting stage 2', 0
BOOT_ERROR       db 'Boot Error. Halting', 0

; uninstantized data
DataSector        dw 0 ; start of the data sector
BootDrive         db 0 ; this stores the boot drive
FirstFATLoc       dw 0 ; Location of first FAT in sectors
BytesPerCluster   dw 0 ; Bytes in each cluster

stage2_start_addr equ 0x10_000

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
	