; This program outputs a message using the 10-th interrupt

.model tiny
.code
org 100h

Start:
	mov si, offset Message	; Address of current character
	mov al, [si]		; Current character
        MessagePrint_loop:
                ; Writing current character:
                mov ah, 0aH
                mov bh, 0
                mov cx, 1
                int 10h
         
                inc si
                mov al, [si]
        
                ; Moving cursor:
                mov ah, 03h
                int 10h
                inc dl
                mov ah, 02h
                int 10h
         

                mov cx, 0
                mov cl, al
                sub cl, '$'
                loopnz MessagePrint_loop


        mov ax, 4c00H
        int 21h

	.data
	Message: db "Hello!$"

end Start
