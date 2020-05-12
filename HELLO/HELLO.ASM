.model tiny
.code
org 100h

Start:		mov ah, 09h
		mov dx, offset Message
		int 21h
		
		mov ax, 4c00h
		int 21h


CR	equ 13
LF	equ 10
CRLF	equ CR, LF
SMILE	equ 1

Message:	db "This is the assembler test ", SMILE, CRLF
		db "New string", '$'

end Start