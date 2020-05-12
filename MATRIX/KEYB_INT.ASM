; This program waits for hotkeys and sorts everything on the screen
; when they are pressed

locals @@

.model tiny

extrn Bubble_Sort: near

.data
hotkeysPressed db 0
oldPalette db 17 dup (0)
matrixPalette 	db 0, 00010000B, 00010000B, 00010010B, \
		00010000B, 00010000B, 00000010B, 00010010B, 00010000B, \ 
		00010010B, 00010010B, 00010010B, 00010000B, 00010010B, \
		00010010B, 00010010B, 0 \

.code
org 100H

Start:
        VIDEO_SEGMENT   equ 0b800H
        SCREEN_WIDTH    equ 80D
        SCREEN_HEIGHT   equ 25D
        KEYB_PORT       equ 60H
        KEYB_INTER      equ 9*4
        JMPFAR_COMMAND  equ 0eaH
	
	cli
	mov ax, 0
	mov es, ax

        mov bx, KEYB_INTER
	mov ax, word ptr es:[bx]
	mov OldInter, ax
	mov ax, word ptr es:[bx+2]
	mov OldInter+2, ax


        mov word ptr es:[bx], offset New09Interrupt
	mov word ptr es:[bx+2], cs                        
	sti

	mov ax, 3100H	; Exit program but don't unload it from RAM
	mov dx, 258H
	int 21H


        New09Interrupt proc
                HOT_KEY_1       equ 2aH ; left shift
                HOT_KEY_2       equ 39H ; space
        
        
                push ax bx cx dx es di ds

		mov ax, cs
		mov ds, ax

                mov bh, HOT_KEY_1
                mov bl, HOT_KEY_2
                call Handle_Hotkeys

                cmp hotkeysPressed, 11000000B
                jne @@end_if_hotkeysPressed
			mov ax, cs		; Saving palette
			mov es, ax
			mov ax, 1009H
			mov dx, offset oldPalette
			int 10H

			mov ax, 1002H		; Setting matrix palette
			mov dx, offset matrixPalette
			int 10H

                        call SortColumns

			mov ax, cs		; Reseting palette
			mov es, ax
			mov ax, 1002H
			mov dx, offset oldPalette
			int 10H
                @@end_if_hotkeysPressed:

                pop ds di es dx cx bx ax
         
                ; Jump to old interrupt handler:
                        db JMPFAR_COMMAND 
        OldInter        dw 0	; jmp arguments
                        dw 0

                iret
                New09Interrupt endp


        ; Handles hotkeys
        ; Input:        bl - first key
        ;               bh - second key
        ; Output:       (var) hotkeysPressed - if i-th bit is 1 (0)
        ;               then the i-th key is pressed (not pressed)
        ; Destroy:      ax
        Handle_Hotkeys proc
                in al, KEYB_PORT
                cmp al, bh
                je @@First_pressed

                cmp al, bl
                je @@Second_pressed

                sub al, 80H
                cmp al, bh
                je @@First_released

                cmp al, bl
                je @@Second_released
                jmp @@end_switch


                @@First_pressed:
                        or hotkeysPressed, 10000000B 
                        jmp @@end_switch

                @@Second_pressed:
                        or hotkeysPressed, 01000000B
                        jmp @@end_switch

                @@First_released:
                        and hotkeysPressed, 01111111B 
                        jmp @@end_switch

                @@Second_released:
                        and hotkeysPressed, 10111111B 
                        jmp @@end_switch
		@@end_switch:

                ret
                Handle_Hotkeys endp

        ; Sorts the columns of the screen
        ; Input:        -
        ; Output:       -
        ; Destroy:      ax, cx, es, di
        SortColumns proc
                mov ax, VIDEO_SEGMENT
                mov es, ax

                mov di, 0       ; Current column
                mov cx, SCREEN_WIDTH
                @@Column_loop:
                        push cx
                        mov cx, (SCREEN_HEIGHT-1)*SCREEN_WIDTH*2
                        call Bubble_Sort
                        pop cx

                        add di, 2
                        loop @@Column_loop

		ret
		SortColumns endp
end Start
