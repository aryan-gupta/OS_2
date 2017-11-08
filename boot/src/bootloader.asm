
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
	; set all the segment registors
	cli
	mov ax, 0x7c0
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	mov bp, 0x8000 ; set the stack
    mov sp, bp
	
	call clr_scr_16
	call hide_cursor_16
	call reset_cursor_16
	
	mov si, ENTRY_MESSAGE
	call print_str_16
	call print_nl_16
	
	mov si, CALL_S2_MESSAGE
	call print_str_16
	call print_nl_16
	
	call load_stage2
	
	mov si, START_S2_MESSAGE
	call print_str_16
	call print_nl_16
	
	call stage2_start_addr
	
	jmp boot_end ; wont run
	

ENTRY_MESSAGE db 'Welcome to OS 2...', 0
LOAD_S2_MESSAGE db 'Loading stage 2...', 0
START_S2_MESSAGE db 'Starting stage 2...', 0

stage2_start_addr equ 0x10_000

boot_end:
	cli
	hlt

times 510-($-$$) db 0
dw 0xaa55
	