; Finds the stage 2 boot loader then loads the bootloader

[BITS 16]
; Loads kernal into memory
; 	al contains num sectors to load
; 	ch contains the cylinder to load
; 	cl constins the sector from which to start
; 	dh constins the track to read from
; 	dl constins the drive to read
load_stage2:
	pusha
	; push dx ; push it because it will be overwritten in inturupt
	
	mov ah, 0x02
	mov al, 0x02 ; 2 sectors to load
	mov ch, 0x00 ; 0 cylinder
	mov cl, 0x02 ; 2nd sector
	mov dh, 0x00 ; 0th head (first side)
	
	mov dl, 0x00 ; drive
	
	int 0x13
	
	jc kernal_load_error
	
	; pop dx
    cmp al, 0x02 ; 'al' is now the # of sectors sucessfully read
    jne kernal_load_error
	
	popa
	ret
	
kernal_load_error:
	mov si, LOAD_ERROR
	call print_str_16
	call print_nl_16
	call boot_end
	
BOOT_DRIVE: db 0
LOAD_ERROR: db 'Error Loading Kernal. Exiting...', 0

