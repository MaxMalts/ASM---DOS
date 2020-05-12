locals @@

.model tiny

extrn Message: byte, Draw_Border: near, Draw_Message: near
.data
borderDrawn db 0


.code
org 100H
Start:
	keybInter	equ 9*4
	jmpFarCommand	equ 0eaH
	
	mov ax, 0
	mov es, ax

	mov bx, keybInter
	mov ax, word ptr es:[bx]
	mov OldInter, ax
	mov ax, word ptr es:[bx+2]
	mov OldInter+2, ax

	mov word ptr es:[bx], offset NewInter
	mov word ptr es:[bx+2], cs                        

	mov ax, 3100H	; Exit program but don't unload it from RAM
	mov dx, 241H
	int 21H

        NewInter proc
                keybPort        equ 60H
                hotKey          equ 2aH ; left shift
        
                push ax bx cx dx ds es di si

		mov ax, cs
		mov ds, ax

                cmp borderDrawn, 0
                jne @@if_borderDrawn
                        in al, keybPort
                        cmp al, hotKey
                        jne @@not_hotKeyPressed
                        	mov BorderDrawn, 1
                        @@not_hotKeyPressed:

                        jmp @@end_if_borderDrawn
                @@if_borderDrawn:
                        call Draw_Border

                        in al, keybPort
			mov Message, 0
                        mov Message+1, al
                        mov Message+2, '$'
			mov di, offset Message

			mov ax, cs
			mov es, ax
                        call Draw_Message
                @@end_if_borderDrawn:

                pop si di es ds dx cx bx ax
         
                ; Data here interprets as code, jumps to old interrupt handler
                        db jmpFarCommand 
        OldInter        dw 0	; jmp arguments
                        dw 0

                iret
                endp
end Start
