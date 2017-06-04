;=====================================================================
; ARKO - program przykladowy do zajec wstepnych z asemblera x86
;
; Autor: Kazimierz Krosman
; Data:  2017-27-03
; Opis:  Funkcja zamieniajaca pierwsza litere ciagu znakowego na 
;        litere 'a'.
;        int func(char *a);
;
;=====================================================================

section	.text
global  func

func:
	push	ebp
	mov	ebp, esp
	; przyklad zaladowania adresów obu argumentów do eax oraz ebx
	mov	eax, DWORD [ebp+12]	;adres *b do eax
	mov	ebx, DWORD [ebp+8]	;adres *a do ebx

	mov	dl, 0

	cmp 	ebx, 0
	je 	end
	mov 	dl, [ebx]
	cmp 	dl, 0
	je	end

loop:
	cmp 	dl, 'a'
	jne 	output
	mov 	dl, 'A'
output:
	mov 	[eax], dl
	inc 	eax
	inc	ebx 
	mov	dl, [ebx]
	cmp 	dl, 0
	jne	loop

end:
	mov 	[eax], dl

	mov	eax, 0			;return 0
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
