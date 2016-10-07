.586
.MODEL FLAT
.stack 4069
.data
num real4 175.5 ; creates num a memory address(variable) equal to 175.5 in IEEE single format
num2 real4 -1.25
num3 real4 -11.75
num4 real4 45.5
.code
main proc
	mov eax, 10
	mov eax, num2
	mov esp, num
	thing:
		cmp eax, 12
		jne thing
	mov eax, 0
	ret
main endp
end