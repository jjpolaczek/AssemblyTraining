;=====================================================================
; ARKO - program przykladowy do zajec wstepnych z asemblera x86
;
; Autor: Jakub Polaczek
; Data:  2017-03.06
; Opis:  Funkcja Filtrująca obraz wyrównaniem histograu
;        int histFilter(unsigned char *pixels, int size);
;
;=====================================================================
section .data
        histTabR times 256 DD 0
	histTabG times 256 DD 0
	histTabB times 256 DD 0
	startAdress DD 0
	iterationNo DB 0
	pixelCount DD 0
	maxVal DD 255
	size DD 0


section	.text
global  histFilter

histFilter:

	push	ebp
	mov	ebp, esp

        push ebx
	push ecx
	push edx
	push esi
	push edi
	; przyklad zaladowania adresów obu argumentów do eax oraz ebx	
	mov	eax, DWORD [ebp+12]	;size do eax
	mov	esi, DWORD [ebp+8]	;adres *pixels do ebx
	;push local vars
	times 4 push 0
	;ebp - 8 - ret val address
	mov ebx,  [ebp+16]
	mov [ebp - 8], ebx
	mov [ebp - 12], eax; size
	mov DWORD [ebp - 16], 0; tmp cumsum


        lea ebx, [size]
	mov [ebx], eax; save size
	;Calculate pixel count
	mov edx, 0
	mov ebx, 3
	idiv ebx
	lea ebx, [pixelCount]
	mov [ebx], eax; save pixel Count
	lea ebx, [startAdress]
	mov [ebx], esi; save pointer

	lea eax, [histTabR]
	lea ecx, [histTabG]
	lea edx, [histTabB]
	mov ebx, 0
zeroloop:
            ;zero out histogram loop
	mov DWORD [eax + ebx], 0
	mov DWORD [ecx + ebx], 0
	mov DWORD [edx + ebx], 0
	add ebx, 4
	cmp ebx, 1024
	jl zeroloop

	mov ecx, 0; counter
        lea eax, [histTabR]
	lea ebx, [histTabG]
	lea ecx, [histTabB]
	lea esi, [startAdress]
	mov esi, [esi];pointer load

        mov edi, [ebp - 12]
	dec edi
	mov edx, 0
histogramLoop:
        mov edx, 0
        mov dl, [esi]
	imul edx, edx, 4
	inc DWORD [ecx + edx]
	mov edx, 0
	mov dl, [esi + 1]
	imul edx, edx, 4
	inc DWORD [ebx + edx]
	mov edx, 0
	mov dl, [esi + 2]
	imul edx, edx, 4
	inc DWORD [eax + edx]
	add esi, 3
	sub edi, 3
	cmp edi, 0
	jge histogramLoop

;mov edx, [ebp - 8]
;mov edi, 0;
;debugloop:
;lea eax, [histTabB]
;add eax, edi
;mov al, [eax]
;mov BYTE [edx + edi], al
;inc edi
;cmp edi, 256
;jl debugloop

	;Store minimum histogram value
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
	lea esi, [histTabR]
	mov edi, 4
	mov DWORD [ebp - 16], 0
	mov DWORD [esi], 0
	lea ebx, [pixelCount]
	mov ebx, [ebx]

cumsumLoopR:
        mov edx, [esi + edi]
	add [ebp - 16], edx
	imul eax, [ebp - 16], 255
	mov edx, 0
	idiv ebx
	mov [esi + edi], al
	add edi, 4
	cmp edi, 1024
	jl cumsumLoopR

        lea esi, [histTabG]
	mov edi, 4
	mov DWORD [ebp - 16], 0
	mov DWORD [esi], 0
	lea ebx, [pixelCount]
	mov ebx, [ebx]

cumsumLoopG:
        mov edx, [esi + edi]
	add [ebp - 16], edx
	imul eax, [ebp - 16], 255
	mov edx, 0
	idiv ebx
	mov [esi + edi], al
	add edi, 4
	cmp edi, 1024
	jl cumsumLoopG

        lea esi, [histTabB]
	mov edi, 4
	mov DWORD [ebp - 16], 0
	mov DWORD [esi], 0
	lea ebx, [pixelCount]
	mov ebx, [ebx]

cumsumLoopB:
        mov edx, [esi + edi]
	add [ebp - 16], edx
	imul eax, [ebp - 16], 255
	mov edx, 0
	idiv ebx
	mov [esi + edi], al
	add edi, 4
	cmp edi, 1024
	jl cumsumLoopB

;lea ebx, [pixelCount]
;mov ebx, [ebx]
;mov edx, [ebp - 8]
;mov [edx], ecx
;jmp exitfun
        ;Lookup table calculation
	;We need to take a pixel color value, run it through the correct LUT array
	;and update pixel value
	;eax - R LUT
	;ebx - G LUT
	;ecx - B LUT
	;esi - data pointer
	;edx - tmp value
	;edi - buffer pointer
LUTcalc:
mov edx, [ebp - 8]
mov edi, 0;
debugloop:
imul esi, edi, 4
lea eax, [histTabR]
add eax, esi
mov eax, [eax]
mov BYTE [edx + edi], al
inc edi
cmp edi, 256
jl debugloop

        lea eax, [histTabR]
	lea ebx, [histTabG]
	lea ecx, [histTabB]
	lea esi, [startAdress]
	mov esi, [esi]

;lea esi, [startAdress]
;mov esi, [esi]
;mov edx, [ebp -8]
;mov [edx], esi

        mov edx, 0
	lea edi, [size]
	mov edi, [edi]
	dec edi
LUTloop:
        mov dl, [esi + edi];load pixel value from buffer
	imul edx, edx, 4 ; translate to word
	mov edx, [eax + edx];look up in LUT table
	mov [esi + edi], dl;write it back
	mov edx, 0
	dec edi
	mov dl, [esi + edi]
	imul edx, edx, 4
	mov edx, [ebx + edx]
	mov [esi + edi], dl
	mov edx, 0
	dec edi
	mov dl, [esi + edi]
	imul edx, edx, 4
	mov edx, [ecx + edx]
	mov [esi + edi], dl
	mov edx, 0

        dec edi
	cmp edi, 0
	jge LUTloop
exitfun:
        mov	eax, 0			;return 0
	times 4 pop eax; delete local vars
        pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	pop	ebp
	ret

;============================================
; STOS
;============================================
;
; wieksze adresy
; 
;  |                             |
;  | ...                         |
;  -------------------------------
;  | parametr funkcji - char *a  | EBP+8
;  -------------------------------
;  | adres powrotu               | EBP+4
;  -------------------------------
;  | zachowane ebp               | EBP, ESP
;  -------------------------------
;  | ... tu ew. zmienne lokalne  | EBP-x
;  |                             |
;
; \/                         \/
; \/ w ta strone rosnie stos \/
; \/                         \/
;
; mniejsze adresy
;
;
;============================================
