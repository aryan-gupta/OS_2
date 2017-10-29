; Contains functions pertaining to printing in 16-bit real mode

[BITS 16]

; prints a letter
; precondition: al stores the letter (8 bits) to be printed
print_ltr_16:
	pusha
	mov ah, 0x0e ; set tty
	int 0x10
	popa
	ret

; Prints a string
; precondition: pointer to string is strored in si
print_str_16:
	pusha
  .ps_repeat:
	lodsb ; loads letter at si to al
	test al, al ; optimized version of cmp al, 0
	je .ps_ret
	call print_ltr_16
	jmp .ps_repeat ; repeat
  .ps_ret:
	popa
	ret

; Prints a new line
print_nl_16:
	pusha	
	mov al, 0x0a ; \n
	call print_ltr_16
	mov al, 0x0d ; \r
	call print_ltr_16
	popa
	ret

; Clears the screen
clr_scr_16: ; http://www.ctyme.com/intr/rb-0097.htm
	pusha
	mov ax, 0x0700
	mov bh, 0x07 ; white on black
	mov cx, 0x0000
	mov dx, 0x184f ; row = 24 (0x18), col = 79 (0x4f)
	int 0x10
	popa
	ret
	
; Hide blinking cursor (its annoying)
hide_cursor_16: ; http://www.ctyme.com/intr/rb-0086.htm
	pusha
	mov ah, 0x01
	mov cx, 0x2607 ; 0010 0110 0000 0111
	int 0x10
	popa
	ret
	
; Move cursor at top left position
reset_cursor_16: ; http://www.ctyme.com/intr/rb-0087.htm
	pusha
	mov ah, 0x02
	xor bx, bx ; https://www.wolframalpha.com/input/?i=a+xor+a
	xor dx, dx
	int 0x10
	popa
	ret
