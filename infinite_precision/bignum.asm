; code for infinite precsion math
.586
.model flat
.stack 65536

.DATA
BIGNUM dword 65536 DUP (0) ; reserve a bunch of memory
OPERATOR dword 65536 DUP (0) ; reserve a bunch of memory
ANSWER dword 65536 DUP (0) ; reserve a bunch of memory for our answer
SAVEFLAGS byte ?
INSTRUC byte ?
CARRYSAVE dword 4 DUP (0)
TEMP dword 65536 DUP (0) ; for saving a copy of our bignum
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
			lahf
			mov SAVEFLAGS, ah ; save our carry flag
			jmp increment
	overflow:
			mov eax, [edi]
			adc [esi], eax
			lahf
			mov SAVEFLAGS, ah
			jmp increment
	continue:
			cmp [edi], 0
			jne overflow ; continue if edi still has stuff
			cmp [esi], 0
			jne overflow ; continue if esi still has stuff
			jmp end
	increment:
			add edi, 4 ; increment our pointers
			add esi, 4 ; increment our pointers
			mov ah, SAVEFLAGS
			sahf ; restore our carry flag
			jc overflow
			jmp continue
	end:
			ret
addition endp

altadd proc ; should be more efficient
	mov eax, [edi]
	add [esi], eax
	jmp continue
	loop:
			mov eax, [edi]
			adc [esi], eax
	continue:
			lahf
			add esi, 4
			add edi, 4
			sahf
			jc loop
			cmp [edi], 0
			jne loop
			cmp [esi], 0
			jne loop
	ret
altadd endp

subtraction proc
; [esi] - [edi]
	mov eax, [edi]
	sub [esi], eax
	jmp continue
	loop:
			mov eax, [edi]
			subb [esi], eax
	continue:
			lahf
			add esi, 4
			add edi, 4
			sahf
			jc loop
			cmp [edi], 0
			jne loop
			cmp [esi], 0
			jne loop
	ret	
subtraction endp

bignum_mul proc
; just copy the behaivor of mul
	xor ecx, ecx
	mov ebx, [esi]
	mul ebx
	mov [esi], ebx
	loop:
		lea edi, CARRYSAVE
		mov [edi], edx ; save the carried part
		add ecx, 4
		add esi, ecx
		cmp [esi], 0
		lahf
		mov SAVEFLAGS, ah ; save our flags, we need zf
		call altadd
		sahf
		je end
		lea esi, BIGNUM
		add esi, ecx
		mov ebx, [esi]
		mul ebx
		mov [esi], ebx
		jmp loop
	end:
		ret
bignum_mul endp

; wip section

multiply_dword proc
; [esi] * [edi]
; this should multiply dwords
	mov ecx, [esi]
	mov edx, [edi]
	xor eax, eax
;	test edx, 00000000000000000000000000000001b
	testit:
		test edx, 1b
		je loop
		add eax, ecx
	loop:
		add ecx, ecx
		shr edx, 1
		cmp edx, 1
		jbe end
		jmp testit
	end:
		add eax, ecx
		ret
multiply_dword endp

multiplication proc

multiplication endp

altmul proc
; [esi] * [edi]
altmul endp

END
