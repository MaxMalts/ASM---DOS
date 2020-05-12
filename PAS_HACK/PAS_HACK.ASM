locals @@

.model tiny

extrn Strcmp: near
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
        call Gets

        ; es and ds already set
        mov si, offset password
        mov di, offset usrInput
        call Strcmp

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
askPassword db 'Password: ', '$'
password db 'mur mur', '$'
usrInput db 32 dup(0)
passwordCorrect db 1


.code
; Reads a string from input
; Input:        es:di - buffer address (be careful with size)
; Output:       In buffer
; Destroy:      ax, di
Gets	proc
        CHAR_INPUT      equ 08H

        @@input_loop:
                mov ah, CHAR_INPUT
                int 21H

		cmp al, CR
		je @@end_input_loop
                cmp al, LF
                je @@end_input_loop
                cmp al, '$'
                je @@end_input_loop
                cmp al, 0
                je @@end_input_loop

                stosb

                jmp @@input_loop
                @@end_input_loop:

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
allowStr db 'Access allowed', '$'


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
denyStr db 'Access denied', '$'

end Start