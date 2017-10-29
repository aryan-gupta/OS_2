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

print_nl_16:
	pusha	
	mov al, 0x0a ; \n
	call print_ltr_16
	mov al, 0x0d ; \r
	call print_ltr_16
	popa
	ret
	