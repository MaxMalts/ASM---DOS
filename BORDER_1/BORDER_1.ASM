locals @@

.model tiny
.code
org 100H

Start:
	call Draw_Border

        mov ax, ds
	mov es, ax 
	mov di, offset Message
	call Draw_message

	mov ax, 4c00H
	int 21H	

	Draw_Border proc
                topLeftChar     equ 'É'
                topChar         equ 'Í'
                topRightChar    equ '»'
                rightChar       equ 'º'
                bottomRightChar equ '¼'
                bottomChar      equ 'Í'
                bottomLeftChar  equ 'È'
                leftChar        equ 'º'
                innerChar       equ ' '
                charColor       equ 01100000B

                mov ax, 0b800H
		mov es, ax

                mov bh, bordTopY    ; Current y axis


                mov al, bh      ; Calculating top left corner position
                mul screenWidth
		mov dh, 0
                mov dl, bordLeftX
                add ax, dx
                add ax, ax
                mov di, ax

                mov ah, charColor       ; Drawing top line
                mov al, topLeftChar
                stosw
                mov al, topChar
		mov ch, 0
                mov cl, bordRightX
                sub cl, bordLeftX
                dec cl 
                rep stosw
                mov al, topRightChar
                stosw
                inc bh

                @@Middle_loop:
                        mov al, bh      ; Calculating current position
                        mul screenWidth
                        mov dh, 0
                        mov dl, bordLeftX
                        add ax, dx
                        add ax, ax
                        mov di, ax
                        
                        mov ah, charColor       ; Drawing current line
                        mov al, leftChar
                        stosw
                        mov al, innerChar
			mov ch, 0
                        mov cl, bordRightX
                        sub cl, bordLeftX
                        dec cl 
                        rep stosw
                        mov al, rightChar
			stosw
                        inc bh

                        cmp bh, bordBottomY
                        loopne @@Middle_loop

                mov al, bh      ; Calculating bottom left corner position
                mul screenWidth
		mov dh, 0
                mov dl, bordLeftX
                add ax, dx
                add ax, ax
                mov di, ax

                mov ah, charColor       ; Drawing bottom line
                mov al, bottomLeftChar
                stosw
                mov al, bottomChar
		mov ch, 0
                mov cl, bordRightX
                sub cl, bordLeftX
                dec cl 
                rep stosw
                mov al, bottomRightChar
                stosw
                inc bh

                ret
                Draw_border endp

	Draw_message proc
                msgColor        equ 01100000B
		
                mov bx, di      ; Saving message address

                mov al, '$'
		mov cx, 0ffffH
                repne scasb

		mov ax, 0b800H
		mov es, ax

                mov cx, di      ; Message length
                sub cx, bx
		dec cx
                mov di, bx

		mov ax, 0
                mov al, msgY    ; Calculating screen position
                mul screenWidth
		mov dh, 0
		mov dl, msgX
                add ax, dx
                add ax, ax
                mov di, ax

                mov ah, msgColor
                @@Print_loop:
                        mov al, [bx]
                        stosw
                        inc bx
                        loop @@Print_loop

                ret
                Draw_message endp

.data
        bordLeftX db 30D
        bordTopY db 12D
        bordRightX db 50D
        bordBottomY db 18D
        screenWidth db 80D
	
	msgX db 37D
	msgY db 15D
        Message db 'Hello$'
	
end Start
