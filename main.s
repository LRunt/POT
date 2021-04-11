	.h8300s
		
		.equ	PUTS,0x0114			;vystup textu na obrazovku
		.equ	GETS,0x0113			;cteni radku z klavesnice
		.equ	syscall,0x1FF00	
	
	 	.data
		
vstup:	.space 100					;maximalni pocet znaku 99 + enter
vystup:	.asciz	"Zadejte text: "
min:	.asciz	"min: "	
max:	.asciz	", max: "
cislo:	.space	2					;vynechane misto pro vysledky (min a max)
		
		.align	2
par1:	.long	vystup
par2:	.long	vstup
par3:	.long	min
par4:	.long	max
par5:	.long	cislo
		
		.align 1
		.space 100
stck:

	 	.text
	 	.global	_start
			
mezera:	cmp.b	R4L,R3L				;konec slova porovnavame pocet pismen s minimalnim poctem pismen
		bcs		mensi
		cmp.b	R4H,R3L				;konec slova porovnavame pocet pismen s maximalnim poctem pismen
		bhi		vetsi
		xor.b	R3L,R3L				;nulovani citace
		rts
		
velke:	cmp.b	#0x41,R0L
		bcc		inkrementace
		jmp		@konecSlova	
		
male:	cmp.b	#0x7A,R0L
		bls		inkrementace
		jmp		@konecSlova
		
mensi:	mov.b	R3L,R4L
		jmp		@mezera

vetsi:	mov.b	R3L,R4H
		jmp		@mezera
		
inkrementace:
		inc.b	R3L					;kdyz pismeno neni mezera inkrementujeme citac
		rts
		
konecSlova:
		cmp.b	#0x00,R3L
		bne     mezera
		rts		
		
pocet:	cmp.b	#0x5A,R0L			;posledni velke pismeno (Z)
		bls		velke	
		cmp.b	#0x61,R0L
		bcc		male
		jmp		konecSlova
	
_start:	mov.l	#stck,ER7			;inicializace zasobniku
		mov.l	#vstup,ER2
		mov.b	#0xFF,R4L			;ulozeni co nejvetsi hodnoty - slova musou byt jen mensi
		mov.b	#0x00,R4H			;ulozeni co nejmensi hondnoty - slova muzou byt jen vetsi
		
		mov.w	#PUTS,R0
		mov.l	#par1,ER1
		jsr		@syscall
		
		mov.w	#GETS,R0
		mov.l	#par2,ER1
		jsr		@syscall
		
		xor.l	ER1,ER1	
		xor.b	R3L,R3L
		
lab1:	mov.b	@ER2,R0L			;nacteni noveho pismena z pameti
		jsr		@pocet				;skok na funkci pocitani pismen v programu
		cmp.b	#0x0A,R0L			;porovnani pismena s ascii enteru
		beq		final				;kdyz je dalsi pismeno enter znamena to konec vstupu
		inc.l	#1,ER2				;dalsi pismeno v pameti
		jmp		@lab1
		
final:	mov.w	#PUTS,R0
		mov.l	#par3,ER1
		jsr		@syscall
		
		jsr		@prevod
		mov.b	R4H,R4L
		
		mov.w	#PUTS,R0
		mov.l	#par5,ER1
		jsr		@syscall
		
		mov.w	#PUTS,R0
		mov.l	#par4,ER1
		jsr		@syscall
		
		jsr		@prevod
		
		mov.w	#PUTS,R0
		mov.l	#par5,ER1
		jsr		@syscall
		
		mov.b	#0x0A,R4L
		mov.b	R4L,@cislo
		mov.w	#PUTS,R0
		mov.l	#par5,ER1
		jsr		@syscall
		
		jmp		@end

prevod:	mov.b	#0x0A,R3H					;prevod hodnot (min, max) do ascii aby se dala zapsat do konzole
		mov.b	#0x30,R3L					;ascii hodnota nuly
		cmp.b	R3H,R4L						;porovnavani cisla (min, max) jestli neni vetsi nez deset
		bcc		desetAVice					
		add.b	#'0',R4L
		mov.b	R4L,@cislo
		rts

desetAVice:									;metoda zajisti vypsani cisel vice nez deset
		inc.b	R3L							;inkrementovani ascii hodnoty o 1
		add.b	#0x0A,R3H					
		cmp.b	R3H,R4L	
		bcc		desetAVice					;porovnavani zda je cislo vetsi nez dvacet, tricet ...
		mov.b	R3L,@cislo					;ukladani ascii hodnoty desitky do pameti
		add.b	#-0x0A,R3H					
		sub.b	R3H,R4L						;odecitani desitek od hodnoty (min, max) -> zbyde nam v registru cislo mensi nez 10
		add.b 	#'0',R4L					;prevod cisla na ascii
		mov.b	R4L,@cislo +1				;ukladani jednotky do pameti 
		rts		
		
end:	bra		end
		.end
		