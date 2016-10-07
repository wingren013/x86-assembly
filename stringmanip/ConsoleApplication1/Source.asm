.586
.MODEL FLAT
.STACK 4096
.data
string byte "this is A stRing Bitches"
table BYTE 48 DUP (' '), "0123456789", 7 DUP (' ')
	BYTE "abcdefghijklmnopqrstuvwxyz", 6 DUP (' ')
	BYTE "abcdefghijklmnopqrstuvwxyz", 133 DUP (' ')
.CODE
main PROC
	lea eax, string ; get length
	push eax ; parameter to be used
	call strlen ; strlen(string)
	add esp, 4 ; remove parameter from stack
	mov ecx, eax ; mov string length to ecx
	lea ebx, table ; get address of table
	lea esi, string ; get address of string
	lea edi, string ; get address of string as destination
forindex: lodsb ; copy next character to al
	xlat ; translate current character
	stosb ; copy character BACK INTO STRING
	loop forindex ; repeat
	mov eax, 0 ; set accumulator to 0
	ret
main endp

strlen proc
	push ebp
	mov ebp, esp
	push ebx
	sub eax, eax
	mov ebx, [ebp+8]
whilechar: cmp byte ptr [ebx], 0
	je endwhilechar
	inc eax
	inc ebx
	jmp whilechar
endwhilechar:
	pop ebx
	pop ebp
	ret
strlen endp

END