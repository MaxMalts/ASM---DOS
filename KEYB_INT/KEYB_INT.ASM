.model tiny
.code
org 100H

Start:
	xor ax, ax	; mov ax, 0
	mov es, ax

	; Intersepting interrupt:
	cli
	mov bx, 9*4	; es:[bx] --> int 09H in ISR Table

	mov ax, word ptr es:[bx]
	mov Old09, ax
	mov ax, word ptr es:[bx+2]
	mov Old09+2, ax
	sti

	mov word ptr es:[bx], offset New09
	mov ax, cs
	mov word ptr es:[bx+2], ax
	
	
	; End program but don't unload it from RAM:
	mov ax, 3100H
	mov dx, 147H
	;shr dx, 4
	int 21h


New09 proc
	; Save registers:
	push ax di es


	mov ax, 0b800H
	mov 	es, ax
	in al, 60H
	mov di, (5*80+40)*2
	mov ah, 4eH
	stosw
	
	;in al, 61H
	;mov ah, al
	;or al, 80H
	;out 61H, al	; To 61 port
	;mov al, ah
	;out 61H, al

	;mov al, 20H
	;out 20H, al	; Send end of interrupt signal

	; Restore registers
	pop es di ax

	; Data here intreprets as code
	db 0eaH		; jmp far
Old09 	dw 0		; jmp arguments
	dw 0
	
	iret
	endp

end Start