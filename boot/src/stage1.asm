
[bits 16]

jmp short stage1_start ; FAT32 needs 3 bytes of code before any declarations
nop

; FAT32 boot sector https://technet.microsoft.com/en-us/library/cc976796.aspx
; nice read: http://board.flatassembler.net/topic.php?p=124387
; http://www.dewassoc.com/kbase/hard_drives/boot_sector.htm
OEM_Identifier        db  'OS_2 0.0'   ; need 8 bytes for OEM Identifier
BytesPerSector        dw  0x200        ; number of bytes per sector -- 512 bytes, its a default
SectorsPerCluster     db  0x8          ; number of sectors per cluster -- 8 sectors is one cluster (files are in 512B * 8 chunks)
ReservedSectors       dw  0x20         ; number of erserved sectors -- always 0x2 on FAT32
NumberOfFATs          db  0x2          ; number of File Allocator Tables
RootEntries           dw  0x0          ; this is always 0 on FAT32
NumberOfSectors       dw  0x0          ; Refer to BigNumberOfSectors
MediaDescriptor       db  0xF8         ; we are on a hard drive
SectorsPerFAT         dw  0x0          ; only used on FAT 12/16 so we set it to 0
SectorsPerTrack       dw  0x3D         ; 
SectorsPerHead        dw  0x2          ; 
HiddenSectors         dd  0x0          ; We eont have any hidden sectors right now
BigNumberOfSectors    dd  0xFE3B1F     ;
BigSectorsPerFAT      dd  0x778
ExtFlags              dw  0x0
FSVersion             dw  0x0          ; File system version, always 0
RootDirectoryStart    dd  0x2          ; Where the root directory starts
FSInfoSector          dw  0x1          ; 
BackupBootSector      dw  0x6
times 12 db 0                          ; 12 bytes are reserved
DriveNumber           db  0x80
Reserved              db  0x0
Signature             db  0x29
VolumeID              dd  0xA88B3652
VolumeLabel           db  "OS_2 BT LDR"
SystemID              db  "FAT32   "

; if we ever do ntfs then this is also a good read http://www.ntfs.com


stage1_start:
	nop
	
	; check for bios extensions
	mov ah, 0x41
	mov bx, 0x55AA ; reverse the bits so we are sure its not garbage
	int 13h
	jc boot_error
	cmp bx, 0AA55h
	jne boot_error
	
	; if we get to this part then we can use LBA or Linear Block Adressing
	; So first calculate where the data section of FAT32 starts -- calculate where the data on FAT32 starts
	; this is calculateed by IndexSector = NumberOfFATs * BigSectorsPerFAT + ReservedSectors
	; https://stackoverflow.com/questions/12030668/how-can-we-use-ex-in-16-bit-but-not-rx-in-32-bit
	xor ah, ah ; reset ah
	mov al, byte [NumberOfFATs] ; the size of the operand is unessary
	mov ebx, dword [BigSectorsPerFAT]
	mul ebx ; result is stored in ax
	xor ebx, ebx
	mov bx, word [ReservedSectors]
	add eax, ebx
	mov [DataSector], eax

	; we need to get the location of the first FAT
	; FirstFAT = ReservedSectors
	; this is kinda redundant, and wastes space, might optimise this later
	mov ax, word [ReservedSectors]
	mov [FirstFATLoc], ax
	
	
	; now we gets the bytes per each cluster
	; BytesPerCluster = BytesPerSector * SectorsPerCluster
	mov ax, [BytesPerSector]
	mov bx, [SectorsPerCluster]
	mul bx
	mov [BytesPerCluster], bx
	
	
; converts cluster into lba adressing scheme
; remeber we enabled BIOS extensions
; LBA = (cluster - 2) * SectorsPerCluster + FirstFATLoc
cluster_to_lba:
	pusha