;=====================================================================
; ARKO - program przykladowy do zajec wstepnych z asemblera x86
;
; Autor: Zbigniew Szymanski
; Data:  2008-11-16
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
	;mov	eax, DWORD [ebp+12]	;adres *b do eax
	;mov	ebx, DWORD [ebp+8]	;adres *a do ebx

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
