; This program requests a password and checks it.
; If it's correct program allows access to the function.
; Uses hash for passwords. If they match then passsword
; is correct.
; To store the password linked list is used. i-th element is
; the t-th letter information. First byte of it is the i-th
; letter and the next 4 bytes are the offset to the next element.
; Password terminates with ('$', 0). All list elements are spread in data.

locals @@

.model tiny

CR	equ 0dH
LF      equ 0aH

.code
org 100H
Start:
        mov ax, cs
        mov ds, ax
        mov dx, offset askPassword
        call Puts

        mov ax, cs
        mov es, ax
        mov di, offset usrInput
	mov cx, INPUT_LENGTH
        call Gets
	
        ; es already set
	mov di, offset pLtr_1
        call calcListHash 
        push ax 

        ; es already set
        mov di, offset usrInput
        call calcBufHash        ; in ax is input hash now

        pop bx  ; Password hash
        cmp ax, bx
        je @@correct
                not passwordCorrect     ; passwordCorrect = !passwordCorrect
                and passwordCorrect, 1
        @@correct:

        cmp passwordCorrect, 0
        je @@if_not_correct
                call AllowAccess
                jmp @@end_if_correct
        @@if_not_correct:
                call DenyAccess
        @@end_if_correct:

        mov ax, 4c00H
        int 21H

.data
pLtr_2		db 'u'
		dw offset pLtr_3

askPassword	db 'Password: ', '$'

pLtr_1		db 'm'	; First letter of password
                dw offset pLtr_2

pLtr_8		db '$'
                dw 0

INPUT_LENGTH	equ 20
usrInput	db INPUT_LENGTH dup(0)

pLtr_3		db 'r'
                dw offset pLtr_4

pLtr_4		db ' '
                dw offset pLtr_5

passwordCorrect	db 1


.code
; Reads a string from input
; Input:        es:di - buffer address (be careful with size)
; 		cx - buffer size
; Output:       In buffer
; Destroy:      ax, cx, di
Gets	proc
        CHAR_INPUT      equ 08H

        @@input_loop:
                mov ah, CHAR_INPUT
                int 21H

		cmp al, CR
		je @@noOverflow
                cmp al, LF
                je @@noOverflow
                cmp al, '$'
                je @@noOverflow
                cmp al, 0
                je @@noOverflow

                stosb

                loop @@input_loop
		dec di	; Overflow so need place for '$'

        @@noOverflow:
        mov al, '$'
        stosb

        ret
        Gets    endp


; Prints '$' - terminated string to console
; Input:        di:dx - string address
; Output:       In console
; Destroy:      ah
Puts    proc
        STRING_OUTPUT   equ 09H

        mov ah, STRING_OUTPUT
        int 21H

        ret
        Puts    endp


; Formula for hash
; Input:        ax - current hash
;               bx - current value
; Output:       ax - new hash
; Destroy:      
HashFormula     proc
        shl ax, 1
        add ax, bx

        ret
        HashFormula     endp
        


; Calculates hash of list elements (must be '$'-terminated,
; '$' isn't calculated in hash)
; Input:        es:di first element address
; Output:       ax - calculated hash
; Destroy:      bx, di
CalcListHash    proc
        xor ax, ax
        mov bl, es:[di]
        @@calculate_loop:
                cmp bl, '$'
                je @@end_calculate_loop
		
		mov bh, 0
                call HashFormula

                inc di
                mov di, es:[di]
                mov bl, [di]

                jmp @@calculate_loop
                @@end_calculate_loop:

        ret
        CalcListHash    endp


; Calculate hash of a buffer (must be '$'-terminated,
; '$' isn't calculated in hash)
; Input:        es:di buffer address
; Output:       ax - calculated hash
; Destroy:      bx, di
CalcBufHash     proc
        xor ax, ax
        mov bl, es:[di]
        @@calculate_loop:
                cmp bl, '$'
                je @@end_calculate_loop

		mov bh, 0
                call HashFormula

                inc di
                mov bl, [di]

                jmp @@calculate_loop
                @@end_calculate_loop:

        ret
        CalcBufHash    endp
        


; Input:        ds:si - password
;               es:di - user input
; Output:       ah - 1: password correct, 0: password incorrect
; Destroy:      si, di, cx
;CheckPassword   proc
;        call Strcmp
;
;        jne @@if_not_correct
;                mov ah, 1
;                jmp @@end_if_correct
;        @@if_not_correct:
;                mov ah, 0
;        @@end_if_correct:
;
;        ret
;        CheckPassword   endp


; Represents a function that will be called
; if passsword is correct, prints 'Access allowed'
; Input:        -
; Output:       In console
; Destroy:      ax, dx, ds
AllowAccess    proc

        mov ax, cs
        mov ds, ax
        mov dx, offset allowStr
        call Puts

        ret
        AllowAccess     endp

.data
pLtr_5		db 'm'
                dw offset pLtr_6

allowStr db CR, LF
        db '      лллл             лллл', CR, LF
	db '      л  л             л  л', CR, LF
	db '      л  лллл       лллл  л', CR, LF
	db '      л     л       л     л', CR, LF
	db '      л  л  ллллллллл  л  л', CR, LF
	db '      л  л   л  л  л   л  л', CR, LF
	db '      л  лл           лл  л', CR, LF
	db '      л                   л', CR, LF
	db '    ллл                   ллл', CR, LF
	db '    л   ллллл       ллллл   л', CR, LF
	db '    л  лл   лл     лл   лл  л', CR, LF
	db '    л   ллллл       ллллл   л', CR, LF
	db '    л                       л', CR, LF
	db ' ллллллллл     ллл     ллллллллл', CR, LF
	db '    л           л           л', CR, LF
        db 'ллллллллл       л       ллллллллл', CR, LF
        db '      л      л  л  л      л', CR, LF
        db '   лллллллл   лл лл   лллллллл', CR, LF
        db '        л               л', CR, LF
        db '        ллллллллллллллллл', CR, LF
        db '$'


pLtr_7		db 'r'
                dw offset pLtr_8


.code
; Represents a function that will be called
; if passsword is incorrect, prints 'access denied'
; Input:        -
; Output:       In console
; Destroy:      ax, dx, ds
DenyAccess      proc

        mov ax, cs
        mov ds, ax
        mov dx, offset denyStr
        call Puts

        ret
        DenyAccess      endp

.data
pLtr_6		db 'u'
                dw offset pLtr_7

denyStr db CR, LF
        db '      лллл             лллл', CR, LF
	db '      л  л             л  л', CR, LF
	db '      л  лллл       лллл  л', CR, LF
	db '      л     л       л     л', CR, LF
	db '      л  л  ллллллллл  л  л', CR, LF
	db '      л  л   л  л  л   л  л', CR, LF
	db '      л  лл           лл  л', CR, LF
	db '      л                   л', CR, LF
	db '    ллл                   ллл', CR, LF
	db '    л   ллллл       ллллл   л', CR, LF
	db '    л  лл   лл     лл   лл  л', CR, LF
	db '    л   ллллл       ллллл   л', CR, LF
	db '    л                       л', CR, LF
	db ' ллллллллл     ллл     ллллллллл', CR, LF
	db '    л           л           л', CR, LF
	db 'ллллллллл       л       ллллллллл', CR, LF
	db '      л         л         л', CR, LF
	db '   лллллллл    л л    лллллллл', CR, LF
	db '        л     л   л     л', CR, LF
        db '        ллллллллллллллллл', CR, LF
        db '$'


end Start
