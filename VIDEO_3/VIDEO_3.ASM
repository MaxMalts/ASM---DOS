; This program outputs a message in border to the screen
; via the video memory. You can adjust the values
; under "User entered data" comment and message under Message variable
; PS: It's same as video_2 but uses string commands

.model tiny
.code
org 100H

Start:
        CR      equ 10D
        LF      equ 13D
        CRLF    equ CR, LF

                ; User entered data:
                scrWidth        equ 80D
        
                msgBegX         equ 30D
                msgBegY         equ 8D

                msgColor        equ 00001111B

                bordBegX        equ 25D
                bordBegY        equ 6D

                bordColor      equ 00001111B 

                ; Characters for border:
                leftTopBord     equ 0c9H
                leftBottomBord  equ 0c8H
                rightTopBord    equ 0bbH
                rightBottomBord equ 0bcH
                LeftBord        equ 0baH
                RightBord       equ 0baH
                TopBord         equ 0cdH
                BottomBord      equ 0cdH

        

        mov ax, 0b800H          ; Video memory
        mov es, ax


        ; Printing message:
        mov bx, offset Message                  ; Current character address
        mov di, (scrWidth*msgBegY+msgBegX)*2D   ; Video position
        mov dl, 0                               ; Message wigth
        mov dh, 1                               ; Message height
        mov cx, 0                               ; For loop
        Message_loop:
                cmp byte ptr [bx], CR
                jne if_not_CR
                        mov al, msgBegY
                        add al, dh
                        mov ah, scrWidth
                        mul ah
                        add ax, msgBegX
                        add ax, ax
                        mov di, ax
                        
                        inc dh
                        add bx, 2D

                        cmp curLineWidth, dl
                        jna if_not_CurMoreMax
                                mov dl, curLineWidth
                        if_not_CurMoreMax:

                        mov curLineWidth, 0
                        jmp end_if_CR
                if_not_CR:
                        mov al, [bx]
                        mov ah, msgColor
                        stosw           ; Print current character
                        inc curLineWidth

                        inc bx
                end_if_CR:

                mov ch, [bx]
                sub ch, '$'
                loopnz Message_loop

        cmp curLineWidth, dl
        jna if_not_CurMoreMax2
                mov dl, curLineWidth
        if_not_CurMoreMax2:

        mov msgWidth, dl        ; Saving message width
        mov msgHeight, dh       ; Saving message height


        ; Generating border:
        ; Calculating corners positions:
        ; bottom left corner:
        mov bh, bordBegX                                ; x axis
        mov bl, bordBegY+(msgBegY-bordBegY)*2D-1D       ; y axis
        add bl, msgHeight
	
	mov cx, 0	; cl - temp bl or bh, to add to ax

        mov al, scrWidth        ; ax - current corner position
        mul bl
        mov cl, bh
        add ax, cx
        add ax, ax
        mov leftBottomCorner, ax

        ; bottom right corner:
        mov bh, bordBegX+(msgBegX-bordBegX)*2D-1D
        add bh, msgWidth

        mov al, scrWidth        ; ax - current corner position
        mul bl
		mov cl, bh
        add ax, cx
        add ax, ax
        mov rightBottomCorner, ax

        ; top right corner:
        mov bl, bordBegY

        mov al, scrWidth        ; ax - current corner position
        mul bl
		mov cl, bh
        add ax, cx
        add ax, ax
        mov rightTopCorner, ax


        ; Printing corner:
        mov di, leftTopCorner   ; Current cursor position

        mov al, leftTopBord
        mov ah, bordColor
        cld
        stosw                   ; Printing top left corner


        ; Top left to right:
        mov cx, rightTopCorner
        sub cx, leftTopCorner
        shr cx, 1
        dec cx
        mov al, TopBord
        mov ah, bordColor
        rep stosw


        mov al, rightTopBord
        mov ah, bordColor
        mov word ptr es:[di], ax        ; Printing top right corner
        add di, scrWidth*2D


        mov al, rightBord
        mov ah, bordColor
        TopToBottomRight_loop:
                mov word ptr es:[di], ax
                add di, scrWidth*2D

                mov cx, di
                sub cx, rightBottomCorner
                loopnz TopToBottomRight_loop


        mov al, rightBottomBord
        mov ah, bordColor
        std
        stosw                   ; Printing bottom right corner


        ; Bottom right to left:
        mov cx, rightBottomCorner
        sub cx, leftBottomCorner
        shr cx, 1
        dec cx
        mov al, TopBord
        mov ah, bordColor
        rep stosw


        mov al, leftBottomBord
        mov ah, bordColor
        mov word ptr es:[di], ax        ; Printing bottom left corner
        sub di, scrWidth*2D

        mov al, leftBord
        mov ah, bordColor
        BottomToTopLeft_loop:
                mov word ptr es:[di], ax
                sub di, scrWidth*2D

                mov cx, di
                sub cx, leftTopCorner
                loopnz BottomToTopLeft_loop


        mov ax, 4c00H   ; Exiting
        int 21H



        .data
        Message db 'Hello!', CRLF, \
		'This is the message', CRLF, \
		'that was drawn directly via', CRLF, \
		'the video memory. alalalaalalallaalalalala$'

        ; Technical variables
        msgWidth db 0
        msgHeight db 0

        curLineWidth db 0

        leftTopCorner dw (scrWidth*bordBegY+BordBegX)*2D
        leftBottomCorner dw 0
        rightTopCorner dw 0
        rightBottomCorner dw 0

end Start
