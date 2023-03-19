.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "A_maze_ing",0
area_width EQU 800
area_height EQU 700
area DD 0
matrice DD 0
matrice_width EQU 23
matrice_height EQU 25
format db " %d ", 0
counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20

element_width EQU 20
element_height EQU 20

sageata_width EQU 41
sageata_height EQU 40

sageata_sus_desen EQU 0
sageata_jos_desen EQU 0
sageata_dreapta_desen EQU 0
sageata_stanga_desen EQU 0

sageata_size EQU 42
sageata_sus_x EQU 80
sageata_sus_y EQU 620

sageata_jos_x EQU 165
sageata_jos_y EQU 620

sageata_dreapta_x EQU 250
sageata_dreapta_y EQU 620

sageata_stanga_x EQU 335
sageata_stanga_y EQU 620

omulet_width EQU 30
omulet_height EQU 30
omulet_desen EQU 0
omulet_x DD 0
omulet_y DD 0
coordonate_initiale_omulet_x DD 0
coordonate_initiale_omulet_y DD 0

final_labirint_x EQU 21
final_labirint_y EQU 25

coord_element_x dd 80
coord_element_y dd 45

tabela_width EQU 25
tabela_height EQU 23

include digits.inc
include letters.inc
include sageata_sus.inc
include sageata_jos.inc
include sageata_dreapta.inc
include sageata_stanga.inc
include lava.inc
include zid.inc
include matrice_din_spate.inc

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y


make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'  ; verificam daca e litera 
	jl make_digit
	cmp eax, 'Z'
	jg make_digit  ; daca nu face jmp e litera
	sub eax, 'A'   ;ramane a cata litera din alfabet e litera noastra
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0ffd11ah
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

make_element proc
	push ebp
	mov ebp, esp
	pusha

	lea esi, elemente
	mov eax, [ebp + arg1]
	
draw_text:
	mov ebx, element_width
	mul ebx
	mov ebx, element_height
	mul ebx
	add esi, eax
	mov ecx, element_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, element_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, element_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0bf4040h
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_element endp

;macro pentru sageata de sus
make_sageata_sus proc
		push ebp
		mov ebp, esp
		pusha
		
		mov eax, [ebp + arg1] ; citim simbolul de afisat
		lea esi, sageata_sus
		jmp draw_sageata_sus

	draw_sageata_sus:
		mov ebx, sageata_width
		mul ebx
		mov ebx, sageata_height
		mul ebx
		add esi, eax
		mov ecx, sageata_height
	bucla_simbol_linii:
		mov edi, [ebp+arg2] ; pointer la matricea de pixeli
		mov eax, [ebp+arg4] ; pointer la coord y
		add eax, sageata_height
		sub eax, ecx
		mov ebx, area_width
		mul ebx
		add eax, [ebp+arg3] ; pointer la coord x
		shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
		add edi, eax
		push ecx
		mov ecx, sageata_width
	bucla_simbol_coloane:
		cmp byte ptr [esi], 0
		je simbol_pixel_alb
		mov dword ptr [edi], 0990033h
		jmp simbol_pixel_next
	simbol_pixel_alb:
		mov dword ptr [edi], 0f4d7d7h
	simbol_pixel_next:
		inc esi
		add edi, 4
		loop bucla_simbol_coloane
		pop ecx
		loop bucla_simbol_linii
		popa
		mov esp, ebp
		pop ebp
		ret
make_sageata_sus endp

make_sageata_jos proc
		push ebp
		mov ebp, esp
		pusha
		
		mov eax, [ebp + arg1] ; citim simbolul de afisat
		lea esi, sageata_jos
		jmp draw_sageata_jos

	draw_sageata_jos:
		mov ebx, sageata_width
		mul ebx
		mov ebx, sageata_height
		mul ebx
		add esi, eax
		mov ecx, sageata_height
	bucla_simbol_linii:
		mov edi, [ebp+arg2] ; pointer la matricea de pixeli
		mov eax, [ebp+arg4] ; pointer la coord y
		add eax, sageata_height
		sub eax, ecx
		mov ebx, area_width
		mul ebx
		add eax, [ebp+arg3] ; pointer la coord x
		shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
		add edi, eax
		push ecx
		mov ecx, sageata_width
	bucla_simbol_coloane:
		cmp byte ptr [esi], 0
		je simbol_pixel_alb
		mov dword ptr [edi], 0990033h
		jmp simbol_pixel_next
	simbol_pixel_alb:
		mov dword ptr [edi], 0f4d7d7h
	simbol_pixel_next:
		inc esi
		add edi, 4
		loop bucla_simbol_coloane
		pop ecx
		loop bucla_simbol_linii
		popa
		mov esp, ebp
		pop ebp
		ret
make_sageata_jos endp


make_sageata_dreapta proc
		push ebp
		mov ebp, esp
		pusha
		
		mov eax, [ebp + arg1] ; citim simbolul de afisat
		lea esi, sageata_dreapta
		jmp draw_sageata_dreapta

	draw_sageata_dreapta:
		mov ebx, sageata_width
		mul ebx
		mov ebx, sageata_height
		mul ebx
		add esi, eax
		mov ecx, sageata_height
	bucla_simbol_linii:
		mov edi, [ebp+arg2] ; pointer la matricea de pixeli
		mov eax, [ebp+arg4] ; pointer la coord y
		add eax, sageata_height
		sub eax, ecx
		mov ebx, area_width
		mul ebx
		add eax, [ebp+arg3] ; pointer la coord x
		shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
		add edi, eax
		push ecx
		mov ecx, sageata_width
	bucla_simbol_coloane:
		cmp byte ptr [esi], 0
		je simbol_pixel_alb
		mov dword ptr [edi], 0990033h
		jmp simbol_pixel_next
	simbol_pixel_alb:
		mov dword ptr [edi], 0f4d7d7h
	simbol_pixel_next:
		inc esi
		add edi, 4
		loop bucla_simbol_coloane
		pop ecx
		loop bucla_simbol_linii
		popa
		mov esp, ebp
		pop ebp
		ret
make_sageata_dreapta endp

make_sageata_stanga proc
		push ebp
		mov ebp, esp
		pusha
		
		mov eax, [ebp + arg1] ; citim simbolul de afisat
		lea esi, sageata_stanga
		jmp draw_sageata_stanga

	draw_sageata_stanga:
		mov ebx, sageata_width
		mul ebx
		mov ebx, sageata_height
		mul ebx
		add esi, eax
		mov ecx, sageata_height
	bucla_simbol_linii:
		mov edi, [ebp+arg2] ; pointer la matricea de pixeli
		mov eax, [ebp+arg4] ; pointer la coord y
		add eax, sageata_height
		sub eax, ecx
		mov ebx, area_width
		mul ebx
		add eax, [ebp+arg3] ; pointer la coord x
		shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
		add edi, eax
		push ecx
		mov ecx, sageata_width
	bucla_simbol_coloane:
		cmp byte ptr [esi], 0
		je simbol_pixel_alb
		mov dword ptr [edi], 0990033h
		jmp simbol_pixel_next
	simbol_pixel_alb:
		mov dword ptr [edi], 0f4d7d7h
	simbol_pixel_next:
		inc esi
		add edi, 4
		loop bucla_simbol_coloane
		pop ecx
		loop bucla_simbol_linii
		popa
		mov esp, ebp
		pop ebp
		ret
make_sageata_stanga endp


; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

make_element_macro macro element, drawArea, x, y
	push y
	push x
	push drawArea
	push element
	call make_element
	add esp, 16
endm

make_sageata_sus_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_sageata_sus
	add esp, 16
endm

make_sageata_jos_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_sageata_jos
	add esp, 16
endm

make_sageata_dreapta_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_sageata_dreapta
	add esp, 16
endm

make_sageata_stanga_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_sageata_stanga
	add esp, 16
endm

matrice_din_spate_func proc
	push ebp
	mov ebp, esp
	lea esi, matrice_din_spate
	mov ebx, 0
	
	mov coord_element_x, 80
	mov coord_element_y, 45
	
linie:	
	mov ecx, tabela_width
coloane:
	push esi
	push ecx
	mov eax, 0
	mov al, byte ptr[esi]

	make_element_macro eax, area, coord_element_x, coord_element_y
	cmp al, 3 
	je salvare_coordonate
	jne nu_salva_coordonatele
	
	salvare_coordonate:
	mov eax, ecx
	mov edx, tabela_width
	sub edx, eax
	mov omulet_x, edx

	mov omulet_y, ebx
	
	nu_salva_coordonatele:
	mov eax, coord_element_x
	add eax, 20
	mov coord_element_x, eax
	
	pop ecx
	pop esi
	inc esi
	
loop coloane
	mov coord_element_x, 80
	mov eax, coord_element_y
	add eax, 20
	mov coord_element_y, eax
	inc ebx
	cmp ebx, tabela_height
	jne linie
	
final:
	mov esp, ebp
	pop ebp
	ret 
matrice_din_spate_func endp

linie_orizontala macro x, y, len, color
local bucla_linie ;facem asta pentru ca folosim macroul in mai multe locuri
	;asa obtinem o adresa la pixelul de inceput
	mov eax, y ; eax == y
	mov ebx, area_width
	mul ebx ; eax = y * area_width
	add eax, x ;eax = y * area_width + x
	shl eax, 2 ; echivalent cu mul * 4 => eax = (y * area_width + x) * 4
	add eax, area
	mov ecx, len
	bucla_linie:
		mov dword ptr[eax], color
		add eax, 4
	loop bucla_linie
endm

linie_verticala macro x, y, len, color
local bucla_linie ;facem asta pentru ca folosim macroul in mai multe locuri
	;asa obtinem o adresa la pixelul de inceput
	mov eax, y ; eax == y
	mov ebx, area_width
	mul ebx ; eax = y * area_width
	add eax, x ;eax = y * area_width + x
	shl eax, 2 ; echivalent cu mul * 4 => eax = (y * area_width + x) * 4
	add eax, area
	mov ecx, len
	bucla_linie:
		mov dword ptr[eax], color
		add eax, area_width * 4
	loop bucla_linie
endm
; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer 
	;mai jos e codul care intializeaza fereastra cu pixeli negri
	
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0
	push area
	call memset
	add esp, 12
	
evt_click:
	mov edx, [ebp + arg2]
	cmp edx, sageata_sus_x
	jl nu_sus
	cmp edx, sageata_sus_x + sageata_size; edx nu eax
	jg nu_sus
	mov edx, [ebp + arg3]
	cmp edx, sageata_sus_y
	jl nu_sus
	cmp edx, sageata_sus_y + sageata_size
	jg nu_sus
	
	click_sageata_sus: 
		mov eax, omulet_y
	    mov ebx, tabela_width
	    mul ebx ; calculam y * nr_coloane
		add eax, omulet_x
		lea esi, matrice_din_spate
		add eax, esi ; adunam adresa matricei, daca facem [eax] obtinem echivalentul matrice[x][y]
		mov ecx, eax
		
		dec omulet_y
		mov eax, omulet_y
		mov ebx, tabela_width
		mul ebx ; calculam y * nr_coloane
		add eax, omulet_x
		add eax, esi ; adunam adresa matricei, daca facem [eax] obtinem echivalentul matrice[x][y]

		mov ebx, 0
		mov bl, byte ptr [eax]
		cmp ebx, 1
		je e_perete_in_sus
		jl mutare_in_sus
		jg e_lava_in_sus
		
		mutare_in_sus:
			mov ebx, 0
			mov byte ptr [ecx], bl
			
			mov ebx, 3
			mov byte ptr [eax], bl
			jmp afiseare_matrice
			
		e_perete_in_sus:
			mov ebx, 0
			mov ebx, 1
			mov byte ptr [eax], bl
			
			mov ebx, 0
			mov ebx, 3
			mov byte ptr [ecx], bl
			jmp afiseare_matrice
			
		e_lava_in_sus:
		
			inc omulet_y
			mov eax, omulet_y
			mov ebx, tabela_width
			mul ebx ; calculam y * nr_coloane
			add eax, omulet_x
			lea esi, matrice_din_spate
			add eax, esi ; adunam adresa matricei, daca facem [eax] obtinem echivalentul matrice[x][y]
			mov ecx, eax
			
			mov eax, coordonate_initiale_omulet_y
			mov ebx, tabela_width
			mul ebx ; calculam y * nr_coloane
			add eax, coordonate_initiale_omulet_y
			add eax, esi ; adunam adresa matricei, daca facem [eax] obtinem echivalentul matrice[x][y]
			
			mov ebx, 0
			mov byte ptr [ecx], bl
				
			mov ebx, 3
			mov byte ptr [eax], bl
			
			mov ebx, coordonate_initiale_omulet_x
			mov omulet_x, ebx
			
			mov ebx, coordonate_initiale_omulet_y
			mov omulet_y, ebx
			jmp afiseare_matrice
	nu_sus:
	mov edx, [ebp + arg2]
	cmp edx, sageata_jos_x
	jl nu_jos
	cmp edx, sageata_jos_x + sageata_size
	jg nu_jos
	mov edx, [ebp + arg3]
	cmp edx, sageata_jos_y
	jl nu_jos
	cmp edx, sageata_jos_y + sageata_size
	jg nu_jos
	
	click_sageata_jos:
		mov eax, omulet_y
	    mov ebx, tabela_width
	    mul ebx ; calculam y * nr_coloane
		add eax, omulet_x
		lea esi, matrice_din_spate
		add eax, esi ; adunam adresa matricei, daca facem [eax] obtinem echivalentul matrice[x][y]
		mov ecx, eax
		
		inc omulet_y
		mov eax, omulet_y
		mov ebx, tabela_width
		mul ebx ; calculam y * nr_coloane
		add eax, omulet_x
		add eax, esi ; adunam adresa matricei, daca facem [eax] obtinem echivalentul matrice[x][y]

		mov ebx, 0
		mov bl, byte ptr [eax]
		cmp ebx, 1
		je e_perete_in_jos
		jl mutare_in_jos
		jg e_lava_in_jos
		
		mutare_in_jos:
			mov ebx, 0
			mov byte ptr [ecx], bl
			
			mov ebx, 3
			mov byte ptr [eax], bl
			jmp afiseare_matrice
			
		e_perete_in_jos:
		    mov ebx, 0
			mov ebx, 1
			mov byte ptr [eax], bl
			
			mov ebx, 0
			mov ebx, 3
			mov byte ptr [ecx], bl
			jmp afiseare_matrice
			
		e_lava_in_jos:
			dec omulet_y
			mov eax, omulet_y
			mov ebx, tabela_width
			mul ebx ; calculam y * nr_coloane
			add eax, omulet_x
			lea esi, matrice_din_spate
			add eax, esi ; adunam adresa matricei, daca facem [eax] obtinem echivalentul matrice[x][y]
			mov ecx, eax
			
			mov eax, coordonate_initiale_omulet_y
			mov ebx, tabela_width
			mul ebx ; calculam y * nr_coloane
			add eax, coordonate_initiale_omulet_y
			add eax, esi ; adunam adresa matricei, daca facem [eax] obtinem echivalentul matrice[x][y]
			
			mov ebx, 0
			mov byte ptr [ecx], bl
				
			mov ebx, 3
			mov byte ptr [eax], bl
			
			mov ebx, coordonate_initiale_omulet_x
			mov omulet_x, ebx
			
			mov ebx, coordonate_initiale_omulet_y
			mov omulet_y, ebx
			jmp afiseare_matrice
			
		
	nu_jos:
	mov edx, [ebp + arg2]
	cmp edx, sageata_dreapta_x
	jl nu_dreapta
	cmp edx, sageata_dreapta_x + sageata_size
	jg nu_dreapta
	mov edx, [ebp + arg3]
	cmp edx, sageata_dreapta_y
	jl nu_dreapta
	cmp edx, sageata_dreapta_y + sageata_size
	jg nu_dreapta
	
	click_sageata_dreapta:
		mov eax, omulet_y
	    mov ebx, tabela_width
	    mul ebx ; calculam y * nr_coloane
		add eax, omulet_x
		lea esi, matrice_din_spate
		add eax, esi ; adunam adresa matricei, daca facem [eax] obtinem echivalentul matrice[x][y]
		mov ecx, eax
		
		inc omulet_x
		mov eax, omulet_y
		mov ebx, tabela_width
		mul ebx ; calculam y * nr_coloane
		add eax, omulet_x
		add eax, esi ; adunam adresa matricei, daca facem [eax] obtinem echivalentul matrice[x][y]

		mov ebx, 0
		mov bl, byte ptr [eax]
		cmp ebx, 1
		je e_perete_la_dreapta
		jl mutare_la_dreapta
		jg e_lava_la_dreapta
		
		mutare_la_dreapta:
			mov ebx, 0
			mov byte ptr [ecx], bl
			
			mov ebx, 3
			mov byte ptr [eax], bl
			jmp afiseare_matrice
			
		e_perete_la_dreapta:
		    mov ebx, 0
			mov ebx, 1
			mov byte ptr [eax], bl
			
			mov ebx, 0
			mov ebx, 3
			mov byte ptr [ecx], bl
			jmp afiseare_matrice
		
		e_lava_la_dreapta:
			dec omulet_x
			mov eax, omulet_y
			mov ebx, tabela_width
			mul ebx ; calculam y * nr_coloane
			add eax, omulet_x
			lea esi, matrice_din_spate
			add eax, esi ; adunam adresa matricei, daca facem [eax] obtinem echivalentul matrice[x][y]
			mov ecx, eax
			
			mov eax, coordonate_initiale_omulet_y
			mov ebx, tabela_width
			mul ebx ; calculam y * nr_coloane
			add eax, coordonate_initiale_omulet_y
			add eax, esi ; adunam adresa matricei, daca facem [eax] obtinem echivalentul matrice[x][y]
			
			mov ebx, 0
			mov byte ptr [ecx], bl
				
			mov ebx, 3
			mov byte ptr [eax], bl
			
			mov ebx, coordonate_initiale_omulet_x
			mov omulet_x, ebx
			
			mov ebx, coordonate_initiale_omulet_y
			mov omulet_y, ebx
			jmp afiseare_matrice
	nu_dreapta:
	
	mov edx, [ebp + arg2]
	cmp edx, sageata_stanga_x
	jl nu_stanga
	cmp edx, sageata_stanga_x + sageata_size
	jg nu_stanga
	mov edx, [ebp + arg3]
	cmp edx, sageata_stanga_y
	jl nu_stanga
	cmp edx, sageata_stanga_y + sageata_size
	jg nu_stanga
	
	click_sageata_stanga: 
		mov eax, omulet_y
	    mov ebx, tabela_width
	    mul ebx ; calculam y * nr_coloane
		add eax, omulet_x
		lea esi, matrice_din_spate
		add eax, esi ; adunam adresa matricei, daca facem [eax] obtinem echivalentul matrice[x][y]
		mov ecx, eax
		
		dec omulet_x
		mov eax, omulet_y
		mov ebx, tabela_width
		mul ebx ; calculam y * nr_coloane
		add eax, omulet_x
		add eax, esi ; adunam adresa matricei, daca facem [eax] obtinem echivalentul matrice[x][y]

		mov ebx, 0
		mov bl, byte ptr [eax]
		cmp ebx, 1
		je e_perete_la_stanga
		jl mutare_la_stanga
		jg e_lava_la_stanga
		
		mutare_la_stanga:
			mov ebx, 0
			mov byte ptr [ecx], bl
			
			mov ebx, 3
			mov byte ptr [eax], bl
			jmp afiseare_matrice
			
		e_perete_la_stanga:
		    mov ebx, 0
			mov ebx, 1
			mov byte ptr [eax], bl
			
			mov ebx, 0
			mov ebx, 3
			mov byte ptr [ecx], bl
			jmp afiseare_matrice	
		
		e_lava_la_stanga:
			inc omulet_x
			mov eax, omulet_y
			mov ebx, tabela_width
			mul ebx ; calculam y * nr_coloane
			add eax, omulet_x
			lea esi, matrice_din_spate
			add eax, esi ; adunam adresa matricei, daca facem [eax] obtinem echivalentul matrice[x][y]
			mov ecx, eax
			
			mov eax, coordonate_initiale_omulet_y
			mov ebx, tabela_width
			mul ebx ; calculam y * nr_coloane
			add eax, coordonate_initiale_omulet_y
			add eax, esi ; adunam adresa matricei, daca facem [eax] obtinem echivalentul matrice[x][y]
			
			mov ebx, 0
			mov byte ptr [ecx], bl
				
			mov ebx, 3
			mov byte ptr [eax], bl
			
			mov ebx, coordonate_initiale_omulet_x
			mov omulet_x, ebx
			
			mov ebx, coordonate_initiale_omulet_y
			mov omulet_y, ebx
			jmp afiseare_matrice
	
	nu_stanga:
	 
	afiseare_matrice:
		call matrice_din_spate_func
		jmp testare_coordonate
evt_timer:
	afisare_chenar_sageti:
		linie_orizontala 80, 620, 42, 0669999h
		linie_orizontala 80, 620 + 42, 42, 0669999h
		linie_verticala 80, 620, 42, 0669999h
		linie_verticala 80 + 42, 620, 42, 0669999h
		
		linie_orizontala 165, 620, 42, 0669999h
		linie_orizontala 165, 620 + 42, 42, 0669999h
		linie_verticala 165, 620, 42, 0669999h
		linie_verticala 165 + 42, 620, 42, 0669999h
		
		linie_orizontala 250, 620, 42, 0669999h
		linie_orizontala 250, 620 + 42, 42, 0669999h
		linie_verticala 250, 620, 42, 0669999h
		linie_verticala 250 + 42, 620, 42, 0669999h
		
		linie_orizontala 335, 620, 42, 0669999h
		linie_orizontala 335, 620 + 42, 42, 0669999h
		linie_verticala 335, 620, 42, 0669999h
		linie_verticala 335 + 42, 620, 42, 0669999h
		
afisare_sageti: 
		make_sageata_sus_macro sageata_sus_desen, area, 80, 622
		make_sageata_jos_macro sageata_jos_desen, area, 165, 622
		make_sageata_dreapta_macro sageata_dreapta_desen, area, 250, 622
		make_sageata_stanga_macro sageata_stanga_desen, area, 335, 622
testare_coordonate:
		mov ecx, omulet_x
		cmp ecx, final_labirint_x
		jl nu_e_afara
		mov ecx, omulet_y
		cmp ecx, final_labirint_y
		jl nu_e_afara
		
a_ajuns_la_final:
			;felicitari
			make_text_macro 'F', area, 665, 175
			make_text_macro 'E', area, 675, 175
			make_text_macro 'L', area, 685, 175
			make_text_macro 'I', area, 695, 175
			make_text_macro 'C', area, 705, 175
			make_text_macro 'I', area, 715, 175
			make_text_macro 'T', area, 725, 175
			make_text_macro 'A', area, 735, 175
			make_text_macro 'R', area, 745, 175
			make_text_macro 'I', area, 755, 175
			;ati
			make_text_macro 'A', area, 700, 200
			make_text_macro 'T', area, 710, 200
			make_text_macro 'I', area, 720, 200
			;ajuns
			make_text_macro 'A', area, 685, 230
			make_text_macro 'J', area, 695, 230
			make_text_macro 'U', area, 705, 230
			make_text_macro 'N', area, 715, 230
			make_text_macro 'S', area, 725, 230
			;la
			make_text_macro 'L', area, 700, 250
			make_text_macro 'A', area, 710, 250
			;final
			make_text_macro 'F', area, 685, 270
			make_text_macro 'I', area, 695, 270
			make_text_macro 'N', area, 705, 270
			make_text_macro 'A', area, 715, 270
			make_text_macro 'L', area, 725, 270
		
			
	nu_e_afara:
		
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc ;se aloca memorie -- se aloca dintr-o data toata matricea -
	add esp, 4
	mov area, eax
	
	;matricea din spate ;)
	mov eax, 20
	mov ebx, 20
	mul ebx
	push eax
	call malloc
	add esp, 4
	mov matrice, eax


	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	;terminarea programului
	push 0
	call exit
end start