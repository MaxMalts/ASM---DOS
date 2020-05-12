; This program outputs a message in border to the screen
; via the video memory. You can adjust the values
; under "User entered data" comment and message under Message variable



.model tiny
.code
org 100h

Start:
        CR      equ 10d
        LF      equ 13d
        CRLF    equ CR, LF

                ; User entered data:
                scrWidth        equ 80d
        
                msgBegX         equ 30d
                msgBegY         equ 8d

                bordBegX        equ 25d
                bordBegY        equ 6d
        
                ; Characters for border:
                leftTopBord     equ 0C9h
                leftBottomBord  equ 0C8h
                rightTopBord    equ 0BBh
                rightBottomBord equ 0BCh
                LeftBord        equ 0BAh
                RightBord       equ 0BAh
                TopBord         equ 0CDh
                BottomBord      equ 0CDh

        

        mov ax, 0B800h          ; Video memory
        mov es, ax


        ; Printing message:
        mov bx, offset Message                  ; Current character address
        mov si, (scrWidth*msgBegY+msgBegX)*2d   ; Video position
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
                        mov si, ax
                        
                        inc dh
                        add bx, 2

                        cmp curLineWidth, dl
                        jna if_not_CurMoreMax
                                mov dl, curLineWidth
                        if_not_CurMoreMax:

                        mov curLineWidth, 0
                        jmp end_if_CR
                if_not_CR:
                        mov ah, [bx]
                        mov es:[si], ah ; Print current character
                        inc curLineWidth
        
                        add si, 2d
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
        mov bl, bordBegY+(msgBegY-bordBegY)*2d-1d       ; y axis
        add bl, msgHeight
	
	mov cx, 0	; cl - temp bl or bh, to add to ax

        mov al, scrWidth        ; ax - current corner position
        mul bl
        mov cl, bh
        add ax, cx
        add ax, ax
        mov leftBottomCorner, ax

        ; bottom right corner:
        mov bh, bordBegX+(msgBegX-bordBegX)*2d-1d
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
        ; Top left to right:
        mov si, leftTopCorner        ; Current cursor position

        mov byte ptr es:[si], leftTopBord       ; Printing top left corner
        add si, 2d

        mov cx, 0       ; For loop
        TopLeftToRight_loop:
                mov byte ptr es:[si], topBord
                add si, 2d

                mov cx, si
                sub cx, rightTopCorner
                loopnz TopLefttoRight_loop

        mov byte ptr es:[si], rightTopBord       ; Printing top right corner
        add si, scrWidth*2d

        mov cx, 0       ; For loop
        TopToBottomRight_loop:
                mov byte ptr es:[si], rightBord
                add si, scrWidth*2d

                mov cx, si
                sub cx, rightBottomCorner
                loopnz TopToBottomRight_loop
        
        mov byte ptr es:[si], rightBottomBord       ; Printing bottom right corner
        sub si, 2d

        mov cx, 0       ; For loop
        BottomRightToLeft_loop:
                mov byte ptr es:[si], bottomBord
                sub si, 2d

                mov cx, si
                sub cx, leftBottomCorner
                loopnz BottomRightToLeft_loop

        mov byte ptr es:[si], leftBottomBord       ; Printing bottom left corner
        sub si, scrWidth*2d

        mov cx, 0       ; For loop
        BottomToTopLeft_loop:
                mov byte ptr es:[si], leftBord
                sub si, scrWidth*2d

                mov cx, si
                sub cx, leftTopCorner
                loopnz BottomToTopLeft_loop


        mov ax, 4C00h   ; Exiting
        int 21h



        .data
        Message db 'Hello!', CRLF, \
		'This is the message', CRLF, \
		'that was drawn directly via', CRLF, \
		'the video memory. alalalaalalallaalalalala$'

        ; Technical variables
        msgWidth db 0
        msgHeight db 0

        curLineWidth db 0

        leftTopCorner dw (scrWidth*bordBegY+BordBegX)*2d
        leftBottomCorner dw 0
        rightTopCorner dw 0
        rightBottomCorner dw 0

end Start
