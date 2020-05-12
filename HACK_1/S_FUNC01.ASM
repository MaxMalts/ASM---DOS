locals @@

.model tiny

public Memchr, Memcmp, Memset, Memcpy, Strlen, Strchr, Strcpy, Strcmp

.code

; Searches for the first byte equal to input.
; Input:        es - memory segment
;               di - address of the first byte of the memory block
;               al - value to search
;               cx - size of memory block
; Output:       di - address of the first equal byte, 0 if not found
; Destroy:      cx
Memchr proc
        repne scasb
        dec di

        cmp es:[di], al
        je @@Found
        mov di, 0
        
        @@Found:
        ret
        Memchr endp

; Compares two memory blocks
; Input:        ds - first memory segment
;               si - first block address
;               es - second memory segment
;               di - second block address
;               cx - blocks size
; Output:       The result in flags as it would "cmp" do
; Destroy:      si, di, cx
Memcmp proc
        repe cmpsb

        ret
        Memcmp endp


; Fills a memory block
; Input:        es - memory segment
;               di - block address
;               al - value
;               cx - blocks size
; Destroy:      di, cx
Memset proc
        rep stosb

        ret
        Memset endp


; Copies block of memory
; Input:        ds - source memory segment
;               si - source block address
;               es - destination memory segment
;               di - destination block address
;               cx - blocks size
; Destroy:      si, di, cx
Memcpy proc
        repe movsb

        ret
        Memcpy endp        


; Calculates the length of string
; Input:        es - memory segment
;               di - string address (max length 0ffffH)
; Output:       ax - length
; Destroy:      di, cx, al
Strlen proc
        mov al, '$'
        mov cx, 0ffffH

        repne scasb

        mov ax, 0fffeH
        sub ax, cx

        ret
        Strlen endp

; Searches for first character entry in string
; Input:        es - memory segment
;               di - string address (max length 0ffffH)
;               al - character
; Output:       di - address of found character, 0 if not found
Strchr proc
        @@Func_loop:
                cmp byte ptr[di], '$'
                je @@Not_found
                cmp [di], al
                je @@Found

                inc di
                jmp @@Func_loop

        @@Not_found:
        mov di, 0
        @@Found:

        ret
        Strchr endp

; Copies string
; Input:        ds - source memory segment
;               si - source string address
;               es - destination memory segment
;               di - destination string address
; Destroy:      si, di
Strcpy proc
        @@Func_loop:
                cmp byte ptr ds:[si], '$'
                movsb

                je @@End_func
                jmp @@Func_loop

        @@End_func:
        ret
        Strcpy endp


; Compares two strings
; Input:        ds - first memory segment
;               si - first string address
;               es - second memory segment
;               di - second string address
; Output:       The result in flags as it would "cmp" do
; Destroy:      si, di, cx

Strcmp proc
        @@Func_loop:
                cmp byte ptr ds:[si], '$'
                jne @@If_FirstNotEnded
                        cmp byte ptr es:[di], '$'
                        jne @@If_SecondNotEnded_1
                                jmp @@End_Func
                        @@If_SecondNotEnded_1:
                                cmp byte ptr es:[di], '$'+1D
                                jmp @@End_func
                @@If_FirstNotEnded:
                        cmp byte ptr es:[di], '$'
                        jne @@If_SecondNotEnded_2
                                cmp byte ptr es:[di], '$'-1
                                jmp @@End_func
                        @@If_SecondNotEnded_2:
                                cmpsb
                                jne @@End_func
                jmp @@Func_loop

        @@End_func:
        ret
        Strcmp endp
end
