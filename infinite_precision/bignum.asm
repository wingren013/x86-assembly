; code for infinite precsion adding
.586
.model flat
.stack 65536

.DATA
BIGNUM dword 65536 DUP (0) ; reserve a bunch of memory
OPERATOR dword 65536 DUP (0) ; reserve a bunch of memory
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
	lea edi, OPERATOR
	cmp INSTRUC, 0
	je addi
	jg multi
	jl subt
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
; [esi] + [edi]
	start:	
			mov eax, [edi] ; move our current section of OPERATOR to eax
			add [esi], eax ; add the current section of OPERATOR to BIGNUM
			mov bl, cf
			jmp increment
	overflow:
			mov eax, [edi]
			adc [esi], eax
			mov bl, cf
			jmp increment
	continue:
			cmp [edi], 0
			jne start ; continue if edi still has stuff
			cmp [esi], 0
			jne start ; continue if esi still has stuff
			jmp end
	increment:
			add edi, 4 ; increment our pointers
			add esi, 4 ; increment our pointers
			mov cf, bl
			jc overflow
			jmp continue
	end:
			ret
addition endp

altadd proc
	start:
			mov eax, [edi]
			add [esi], eax
			mov bl, cf
			add esi, 4
			add edi, 4
			mov cf, bl
			jnc continue
			mov eax, [edi]
			adc [esi], eax
			mov eax, [edi+4]
			adc [esi+4], eax
	continue:
			cmp [edi], 0
			jne start
			cmp [esi], 0
			jne start
	end:
			ret
altadd endp

subtraction proc
; [esi] - [edi]
	start:
			mov eax, [edi]
			sub [esi], eax
	
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
