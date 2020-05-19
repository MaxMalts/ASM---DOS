; This program prints a border with a message inside.
; You can set the border properties and the message
; in data segment.

locals @@

.model tiny

public Message, Draw_Border, Draw_Message
.data
		bordLeftX db 35D
		bordTopY db 10D
		bordRightX db 45D
		bordBottomY db 14D
		screenWidth db 80D
		
		msgX db 39D
		msgY db 12D
		Message db 'Hello$'


.code
Start:

		; Draws border
		; Input:
		; Variables:    bordLeftX db 30D
		;               bordTopY db 12D
		;               bordRightX db 50D
		;               bordBottomY db 18D    
		;				screenWidth
		; Destroy:      ax, bx, cx, di, es
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

					call Draw_shadow

					ret
					Draw_border endp


        ; Draws shadow of the border
        ; Input:
        ; Variables:    bordLeftX db 30D
        ;               bordTopY db 12D
        ;               bordRightX db 50D
        ;               bordBottomY db 18D    
		;		        screenWidth
        ; Destroy:      ax, bx, cx, di, es
        Draw_shadow proc
                ShadowColor     equ 01110000B

                mov ax, 0b800H
				mov es, ax

                mov bh, bordBottomY     ; Bottom left y axis
                inc bh

                mov al, bh      ; Calculating bottom left corner position
                mul screenWidth
				mov dh, 0
                mov dl, bordLeftX
                inc dl
                add ax, dx
                add ax, ax
                mov di, ax

                mov al, shadowColor     ; Drawing bottom shadow
				mov ch, 0
                mov cl, bordRightX
                sub cl, bordLeftX
                inc cl
                @@bottom_loop:
                        inc di
                        stosb
                        loop @@bottom_loop
                dec di

                mov cl, bordBottomY     ; Drawing left shadow
                sub cl, bordTopY
                @@left_loop:
                        sub di, 80D*2D
                        mov es:[di], al
                        loop @@left_loop

                ret
                Draw_shadow endp


		; Draws message in border
		; Input:        di - message address
		;       		es - message address segment
		; Variables:    screenWidth
		;               MsgX
		;               MsgY
		; Destroy:		ax, bx, cx, dx, es, di
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
end Start
