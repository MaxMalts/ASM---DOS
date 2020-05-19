locals @@

.model tiny

public Bubble_Sort

.data
dataArray db 6, 8, 3, 9, 3, 6, 4, 7, 2, 3
dataSize dw 10D

.code
VIDEO_SEGMENT   equ 0b800H
SCREEN_WIDTH    equ 80D
SCREEN_HEIGHT   equ 25D
SLEEP_AMT	equ 1000H

; Sorts an array of bytes
; Input:        es - array address segment
;               di - array address
;               cx - array size
; Detroy:       ax, bx, cx, dx
Bubble_Sort proc
        arrOffset       equ SCREEN_WIDTH*2D   ; Offset between elements in memory

        sub cx, arrOffset
        @@Sort_loop:
                mov dx, 0       ; Current element index
                
                @@SortInner_loop:
                        mov bx, di
                        add bx, dx
                        
                        mov al, es:[bx]
                        mov ah, es:[bx+arrOffset]
						push bx
                        call ChCmp
						cmp bh, 2
						pop bx
                        jb @@end_if_inverse
                                mov ah, es:[bx+arrOffset]
                                mov es:[bx], ah
                                mov es:[bx+arrOffset], al
                        @@end_if_inverse:

                        add dx, arrOffset
                        cmp dx, cx
                        jne @@SortInner_loop

                push cx
                call Sleep
                pop cx

                sub cx, arrOffset
                cmp cx, 0
                jne @@Sort_loop

        ret
        Bubble_Sort endp

; Compares two characters
; (space is less than every character,
; all other characters are same)
;
; Input:        al, ah - two characters
; Output:       bh: 0 - if al<ah, 1 - al=ah, 2 - al>ah
ChCmp proc
        cmp al, ' '
        jne @@if_not_alSpace
                cmp ah, ' '
                jne @@if_not_ahSpace1
                        mov bh, 1
                        jmp @@end_proc
                @@if_not_ahSpace1:
                        mov bh, 0
                        jmp @@end_proc

        @@if_not_alSpace:
                cmp ah, ' '
                jne @@if_not_ahSpace2
                        mov bh, 2
                        jmp @@end_proc
                @@if_not_ahSpace2:
                        mov bh, 1
                        jmp @@end_proc

        @@end_proc:
        ret
        ChCmp   endp

	; Sleeps
	; Destroy:	cx
	Sleep proc
		mov cx, SLEEP_AMT
		@@Sleep_loop:
			loop @@Sleep_loop

		ret
		Sleep endp
end
