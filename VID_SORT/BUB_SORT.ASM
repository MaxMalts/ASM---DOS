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

; Sorts an array of bytes
; Input:        es - array address segment
;               di - array address
;               cx - array size
; Detroy:       ax, bx, cx, dx
Bubble_Sort proc
        arrOffset       equ 2   ; Offset between elements in memory

        sub cx, arrOffset
        @@Sort_loop:
                mov dx, 0       ; Current element index
                
                @@SortInner_loop:
                        mov bx, di
                        add bx, dx

                        mov al, es:[bx]
                        cmp al, es:[bx+arrOffset]
                        jb @@if_not_inverse
                                mov ah, es:[bx+arrOffset]
                                mov es:[bx], ah
                                mov es:[bx+arrOffset], al
                        @@if_not_inverse:

                        add dx, arrOffset
                        cmp dx, cx
                        jne @@SortInner_loop

                sub cx, arrOffset
                cmp cx, 0
                jne @@Sort_loop

        ret
        Bubble_Sort endp
end