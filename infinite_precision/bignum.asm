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
	mov ecx, 65536
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
			cmp ecx, 0
			jne overflow ; continue if our counter is not 0
			jmp end
	increment:
			add edi, 4 ; increment our pointers
			add esi, 4 ; increment our pointers
			mov ah, SAVEFLAGS	
			dec ecx ; decrement our counter
			sahf ; restore our carry flag
			jc overflow
			jmp continue
	end:
			ret
addition endp

; y altadd and subtraction assume that no 0000 0000 0000 0000 0000 0000 0000 0000 section will exist in the number. Need to fix this.

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
		shl edx, 1
		shr edx, 1
		cmp edx, 1
		jbe end
		jmp testit
	end:
		add eax, ecx
		ret
multiply_dword endp


multiplication proc
	load:
		lea esi, BIGNUM
		lea edi, OPERATOR
		mov eax, 65536 ; set our counter
	OPset:
		add edi, 4
		dec eax
		jne OPset ; keep going if not z
	stuff:
		
	increment:
		add edi, 4
		add esi, 4
	decrement:
		sub edi, 4
		sub esi, 4
	double: ; double the first column
		shl [esi], 1
		add esi, 4
		adc [esi], 0 ; we don't need to handle possible overflow here
	halve: ; halve the first column
		shr [edi], 1
		sub edi, 4
		jnc stuff ; continue if no carry
		;if carry add 2^31
		add 10000000000000000000000000000000b ; 2^31 we don't need to handle overflow
		jmp stuff
	end:
		xor eax, eax
		ret
multiplication endp

altmul proc
; [esi] * [edi]
altmul endp


END
