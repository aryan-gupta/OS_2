
; Stage 1 bootloader
; This stage only outputs minimal text and loads the 2nd stage
; This uses FAT32 to do this
[BITS 16]

[org 0x7c00] ; we are going to have to set the segments too

jmp short boot_start ; FAT32 needs 3 bytes of code before any declarations
nop

; FAT32 boot sector https://technet.microsoft.com/en-us/library/cc976796.aspx
OEM_ID                db  'OS_2 0.0'   ; need 8 bytes for OEM Identifier
BytesPerSector        dw  0x200        ; number of bytes per sector -- little endian
SectorsPerCluster     db  0x8          ; number of sectors per cluster
ReservedSectors       dw  0x20         ; number of erserved sectors -- just the boot sector
TotalFATs             db  0x2          ; number of File Allocator Tables
MaxRootEntries        dw  0x0          ;  this is reserved and will not be set
NumberOfSectors       dw  0x0          ; also reserved
MediaDescriptor       db  0xF8         ; we are on a hard drive
SectorsPerFAT         dw  0x0          ; only used on FAT 12/16 so we set it to 0
SectorsPerTrack       dw  0x3D         ; sectors per track
SectorsPerHead        dw  0x2          ; 
HiddenSectors         dd  0x0          ; 
TotalSectors          dd  0xFE3B1F	   ;
BigSectorsPerFAT      dd  0x778
Flags                 dw  0x0
FSVersion             dw  0x0
RootDirectoryStart    dd  0x2
FSInfoSector          dw  0x1
BackupBootSector      dw  0x6
times 12 db 0                          ; 12 bytes are reserved
DriveNumber           db  0x80
Reserved              db  0x0
Signature             db  0x29
VolumeID              dd  0xA88B3652
VolumeLabel           db  "OS_2 BT LDR"
SystemID              db  "FAT32   "


%include "src/print_16.asm"
%include "src/load_kernal.asm"

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
	
	call load_kernal
	
	mov si, KERNAL_LOADED
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
KERNAL_LOADED: db 'Kernel loaded sucessfully', 0
SWITCH_32: db 'Switching to 32-bit Mode', 0
	

boot_end:
	jmp $

times 510-($-$$) db 0
dw 0xaa55
	