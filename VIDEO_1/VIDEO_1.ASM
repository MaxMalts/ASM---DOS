.model tiny
.code
org 100h

Start:
        mov dx, 0b800h                  ; Video memory segment
        mov es, dx 

        mov si, offset Text             ; Text address
        mov bx, (80d*12d + 30d)*2d      ; Starting point
        mov ah, [si]                    ; Current character
        mov cl, 0
	Print_loop:
                mov es:[bx], ah         ; Writing to video memory
		mov byte ptr es:[bx + 1], 00001100b

                inc si
                add bx, 2
                            
                mov ah, [si]            ; Current character

                mov ch, ah
		sub ch, '$'
                loopnz Print_loop
                

	mov ah, 4ch
	mov al, 00h
        int 21h         ; Exiting

.data
Text:	db "Hello world$"

end Start
