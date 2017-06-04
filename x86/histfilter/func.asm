;=====================================================================
; ARKO - program przykladowy do zajec wstepnych z asemblera x86
;
; Autor: Jakub Polaczek
; Data:  2017-03.06
; Opis:  Funkcja Filtrująca obras wyrównaniem histograu
;        int histFilter(unsigned char *pixels, int size);
;
;=====================================================================
section .data
        histTabR times 255 DB 0
	histTabG times 255 DB 0
	histTabB times 255 DB 0
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

        lea ebx, [size]
	mov [ebx], eax; save size
	;Calculate pixel count
	mov edx, 0
	mov ebx, 3
	sub eax, 1
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
	mov DWORD [eax], 0
	mov DWORD [ecx], 0
	mov DWORD [edx],  0
	add eax, 4
	add ecx, 4
	add edx, 4

        add ebx, 4
	cmp ebx, 255
	jle zeroloop
	mov ecx, 0; counter

        lea eax, [histTabR]
	lea ebx, [histTabG]
	lea ecx, [histTabB]
	lea esi, [startAdress]
	mov esi, [esi];pointer load
	lea edi, [size]
	mov edi, [edi]
	mov edx, 0
histogramLoop:
        mov dl, [esi]
	inc BYTE [ecx + edx]
	mov dl, [esi + 1]
	inc BYTE [ebx + edx]
	mov dl, [esi + 2]
	inc BYTE [eax + edx]
	add esi, 3
	sub edi, 3
	cmp edi, 0
	jle histogramLoop



        mov edx, 0
	;Store minimum histogram value
	;The loop runs three times over each channel
	;First we get starting values
	;Then we run over 256 array values
	;Then we run again and again untl all buffers are iterated
	;edi is the current loop iterator value
	;we need eax for multiplication imul eax[var]
	;edx:eax/ebx => eax for idiv ebx
	;ecx - minimal value from histogram
	;edx - temporary load variable
	;esi - base data pointer
	;First prepare by storing iteration number in the variable
	lea ebx, [size]
	mov ebx, [ebx]
	lea edx, [iterationNo]
	mov DWORD [edx], 0
	mov ecx, 0
	lea esi, [histTabR]
	mov cl, [esi]
	sub [esi], cl; write first value
	mov edi, 1
	mov edx, 0
cumsumLoop:
        mov dl, [esi + edi];B

        sub edx, ecx
	imul eax, edx, 255
	mov edx, 0
	idiv ebx
	mov [esi + edi], al

        inc edi
	cmp edi, 255
	jle cumsumLoop;iterate over single color
	;Increment and check iterration number
	lea edx, [iterationNo]
	inc DWORD [edx]
	cmp DWORD [edx], 3
	je LUTcalc
	;here if not jumping and next iteration
	add esi, 256
	;Get next min values and rewrite first value
	mov ecx, 0
	mov cl, [esi]
	sub [esi], cl

        mov edi, 1
	jmp cumsumLoop
LUTcalc:

        mov	eax, 0			;return 0

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
