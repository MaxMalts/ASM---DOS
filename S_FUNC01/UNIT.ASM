.model tiny

.data
extrn Memchr:near, Memcmp:near, Memset:near, Memcpy:near, \
      Strlen:near, Strchr:near, Strcpy:near, Strcmp:near
string1 db "This is the first string$"
string2 db "This is the second string$"
array db 8 dup(0)
string db 30 dup(0)

.code
org 100H

Start:
        mov al, 'e'
        mov di, offset string1
        mov cx, 14D
        call Memchr

        mov si, offset string1
        mov di, offset string2
        mov cx, 15D
        call Memcmp

        mov di, offset array
        mov al, 'y'
        mov cx, 5D
        call Memset

        mov si, offset string1
        mov di, offset array
        mov cx, 6D
        call Memcpy

        mov di, offset string1
        call Strlen

        mov di, offset string1
        mov al, 'e'
        call Strchr

        mov si, offset string1
        mov di, offset string
        call Strcpy

        mov si, offset string1
        mov di, offset string2
        call Strcmp

        mov ax, 4c00H
        int 21H

        end Start
