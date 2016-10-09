; code for infinite precsion adding
.586
.model flat
.stack 65536

.DATA
BIGNUM dword 65536 DUP (0) ; reserve a bunch of memory
TEMP dword 65536 DUP (0) ; reserve a bunch of memory
ANSWER dword 65536 DUP (0) ; reserve a bunch of memory for our answer
INSTRUC byte 0
BASE byte ? ; we need to know the base for obvious reasons
.CODE

main proc
	xor eax, eax ; set accumulator to 0
	push ebp
	mov ebp, esp
main endp

math proc
	lea esi, BIGNUM
	lea edi, TEMP
	cmp INSTRUC, 0
	je addi
	jg multi
	jl subt
	mov eax, -1
	jmp end
	addi:
			call addition
			jmp end
	subt:
			call subtraction
			jmp end
	multi:
			call mulitplication
			jmp end
	end:
		ret
math endp

;pseudocode
; two possible implementations:
; store an array of digits and a number representing the number of digits, preform math one digit at a time
; store an array of dwords and treat it as a very big binary representation number

addition proc
; [esi] + [edi] = [ecx]
	XOR ecx, ecx

	RET
addition endp

subtraction proc
; [esi] - [edi] = [ecx]
	XOR ecx, ecx
	MOV [ecx], [esi]
	SUB [ecx], [edi]
	XOR eax, eax
	RET
subtraction endp

multiplication proc
; [esi] * [edi] = [ecx] := eax
	XOR ecx, ecx
	LEA ecx
	start:
			ADD [ecx], [esi]
			DEC [edi]
			JNZ start
	end:
	RET
multiplication endp

END
