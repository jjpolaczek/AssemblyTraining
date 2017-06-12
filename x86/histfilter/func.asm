;=====================================================================
; ARKO - program przykladowy do zajec wstepnych z asemblera x86
;
; Autor: Jakub Polaczek
; Data:  2017-03.06
; Opis:  Funkcja Filtrująca obraz wyrównaniem histograu
;        int histFilter(unsigned char *pixels, int size);
;
;=====================================================================
default rel

section .data
        histTabR times 256 DD 0
	histTabG times 256 DD 0
	histTabB times 256 DD 0
	startAdress DQ 0
	iterationNo DB 0
	pixelCount DD 0
	contrast DQ 0
	size DD 0


section	.text
global  histFilter
;r12, r13, r14, r15, rbx, rsp, rbp
histFilter:

        push	rbp
	mov	rbp, rsp

        push rbx
	push rdi
	push rsi
	push r15
	push r14
	push r13
	push r12
	;push local vars
	push rdx;rbp - 64 is for debug
	times 3 push 0

        mov rax, 0
	mov rdx, [rbp - 64] ; load rdx from stack test
	mov QWORD [rbp - 72], 0; tmp cumsum
	;mov r8, [rbp + 16]



        mov rax, rsi
	lea rbx, [size]
	mov [rbx], eax; save size - lower rax values

        lea rbx, [contrast]
	mov [rbx], rcx
	;Calculate pixel count
	mov edx, 0
	mov ebx, 3
	idiv ebx
	lea rbx, [pixelCount]
	mov [rbx], eax; save pixel Count
	lea rbx, [startAdress]
	mov [rbx], rdi; save pointer



        lea rax, [histTabR]
	lea rcx, [histTabG]
	lea rdx, [histTabB]
	mov rbx, 0
zeroloop:
            ;zero out histogram loop
	mov DWORD [rax + rbx], 0
	mov DWORD [rcx + rbx], 0
	mov DWORD [rdx + rbx], 0
	add rbx, 4
	cmp rbx, 1024
	jl zeroloop

        lea rcx, [contrast]
	cmp DWORD [rcx], 0
	jne contrastLUT

        mov rcx, 0; counter
	lea rax, [histTabR]
	lea rbx, [histTabG]
	lea rcx, [histTabB]
	lea rsi, [startAdress]
	mov rsi, [rsi];pointer load

        lea rdi, [size]
	mov rdi, [rdi]
	dec rdi
	mov rdx, 0
histogramLoop:
        mov edx, 0
	mov dl, [rsi]
	imul edx, edx, 4
	inc DWORD [rcx + rdx]
	mov edx, 0
	mov dl, [rsi + 1]
	imul edx, edx, 4
	inc DWORD [rbx + rdx]
	mov edx, 0
	mov dl, [rsi + 2]
	imul edx, edx, 4
	inc DWORD [rax + rdx]
	add rsi, 3
	sub rdi, 3
	cmp rdi, 0
	jge histogramLoop


	;The loop runs three times over each channel
	;First we get starting values
	;Then we run over 256 array values
	;Then we run again and again untl all buffers are iterated
	;edi is the current loop iterator value
	;we need eax for multiplication imul eax[var]
	;edx:eax/ebx => eax for idiv ebx
	;[ebp - 16]- cumulative sum
	;edx - temporary load variable
	;esi - base data pointer
	;First prepare by storing iteration number in the variable
	lea rsi, [histTabR]
	mov rdi, 4
	mov QWORD [rbp - 72], 0
	mov QWORD [rsi], 0
	lea rbx, [pixelCount]
	mov ebx, [rbx]

cumsumLoopR:
        mov edx, [rsi + rdi]
	add [rbp - 72], edx
	imul eax, [rbp - 72], 255
	mov edx, 0
	idiv ebx
	mov [rsi + rdi], eax
	add rdi, 4
	cmp rdi, 1024
	jl cumsumLoopR

        lea rsi, [histTabG]
	mov rdi, 4
	mov QWORD [rbp - 72], 0
	mov QWORD [rsi], 0
	lea rbx, [pixelCount]
	mov ebx, [rbx]

cumsumLoopG:
        mov edx, [rsi + rdi]
	add [rbp - 72], edx
	imul eax, [rbp - 72], 255
	mov edx, 0
	idiv ebx
	mov [rsi + rdi], eax
	add rdi, 4
	cmp rdi, 1024
	jl cumsumLoopG

        lea rsi, [histTabB]
	mov rdi, 4
	mov QWORD [rbp - 72], 0
	mov QWORD [rsi], 0
	lea rbx, [pixelCount]
	mov ebx, [rbx]

cumsumLoopB:
        mov rdx, 0
	mov edx, [rsi + rdi]
	add [rbp - 72], rdx
	imul rax, [rbp - 72], 255

        mov edx, 0
	idiv ebx
	;mov [rsi + rdi], eax
	mov [rsi + rdi], eax
	add rdi, 4
	cmp rdi, 1024
	jl cumsumLoopB


        jmp LUTcalc

contrastLUT:

    lea rbx, [contrast]
    mov rax, [rbx]

    mov rbx, 259
    sub rbx, rax
    imul rbx, 255;255(259-C)

    add rax, 255
    imul rax, 259;259(255+C)
    cvtsi2ss xmm0, eax
    cvtsi2ss xmm1, ebx
    divss xmm0, xmm1

    lea rax, [histTabR]
    lea rbx, [histTabG]
    lea rcx, [histTabB]
    mov r9, 0
contrastLoop:
    mov r8,r9
    imul r8, 4
    ;mov rdx, r9
    mov rdx, r9
    sub edx, 128
    cvtsi2ss xmm1, edx
    mulss xmm1, xmm0
    cvtss2si edx, xmm1
    add edx, 128
    cmp edx, 0
    jge biggertz
    mov edx, 0
biggertz:
    cmp edx, 256
    jl lesst256
    mov edx, 255
lesst256:
    mov [rax+r8], edx
    mov [rbx+r8], edx
    mov [rcx+r8], edx
    inc r9
    cmp r9, 256
    jl contrastLoop
    ;Push to fp registers

lea rsi, [histTabG]
mov rax, 0
mov rdx, [rbp - 64] ; load rdx from stack test
mov rcx, rsi
testor1:
mov rbx, [rcx + rax]; load hist val
mov [rdx + rax], ebx
add rax, 4
cmp rax, 1024
jl testor1


;lea ebx, [pixelCount]
;mov ebx, [ebx]
;mov edx, [ebp - 8]
;mov [edx], ecx
;jmp exitfun
        ;Lookup table calculation
	;We need to take a pixel color value, run it through the correct LUT array
	;and update pixel value
	;rax - R LUT
	;rbx - G LUT
	;rcx - B LUT
	;rsi - data pointer
	;rdx - tmp value
	;rdi - buffer pointer
LUTcalc:

        lea rax, [histTabR]
	lea rbx, [histTabG]
	lea rcx, [histTabB]
	lea rsi, [startAdress]
	mov rsi, [rsi]
	mov rdx, 0
	lea rdi, [size]
	mov rdi, [rdi]
	dec rdi
LUTloop:
        mov dl, [rsi + rdi];load pixel value from buffer
	imul rdx, rdx, 4 ; translate to word
	mov rdx, [rax + rdx];look up in LUT table
	mov [rsi + rdi], dl;write it back
	mov edx, 0
	dec rdi
	mov dl, [rsi + rdi]
	imul rdx, rdx, 4
	mov rdx, [rbx + rdx]
	mov [rsi + rdi], dl
	mov rdx, 0
	dec rdi
	mov dl, [rsi + rdi]
	imul rdx, rdx, 4
	mov rdx, [rcx + rdx]
	mov [rsi + rdi], dl
	mov rdx, 0

        dec rdi
	cmp rdi, 0
	jge LUTloop
exitfun:
        mov	eax, 0			;return 0
	times 4 pop r11; delete local vars
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	pop	rsi
	pop	rdi
	pop	rbx
	pop	rbp
	ret
