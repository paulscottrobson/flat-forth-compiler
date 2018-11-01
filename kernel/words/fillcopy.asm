; *********************************************************************************
; *********************************************************************************
;
;		File:		copyfill.asm
;		Purpose:	Data Copy and Fill
;		Date:		30th October 2018
;		Author:		paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;
;						Fill [Count] bytes with B starting at A
;
; *********************************************************************************

; @forth fill
		ld 		a,b 								; nothing to do.
		or 		c
		ret 	z
		push	bc
		push 	hl
		
__fill1:ld 		(hl),e
		inc 	hl
		dec 	bc
		ld 		a,b
		or 		c
		jr 		nz,__fill1

		pop 	hl
		pop 	bc
		ret

; *********************************************************************************
;
;					Move (actually copy) C bytes from B to A
;
; *********************************************************************************

; @forth move
		ld 		a,b 								; nothing to do.
		or 		c
		ret 	z

		push 	bc
		push 	de
		push 	hl

		xor 	a 									; find direction. 
		sbc 	hl,de
		ld 		a,h
		add 	hl,de
		bit 	7,a 								; if +ve use LDDR
		jr 		z,__copy2

		ex 		de,hl 								; LDIR etc do (DE) <- (HL)
		ldir
__copyExit:
		pop 	hl
		pop 	de
		pop 	bc
		ret

__copy2:		
		add 	hl,bc 								; add length to HL,DE, swap as LDDR does (DE) <- (HL)
		ex 		de,hl
		add 	hl,bc
		dec 	de 									; -1 to point to last byte
		dec 	hl
		lddr 
		jr 		__copyExit		

