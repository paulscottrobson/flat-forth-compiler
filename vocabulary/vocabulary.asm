; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		vocabulary.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		22nd December 2018
;		Purpose :	Core vocabulary
;
; ***************************************************************************************
; ***************************************************************************************

		opt 	zxNextReg
		org 	$0000

Parameter = $8008

; ***************************************************************************************
;										Stack operations
; ***************************************************************************************

;; a>r
		push 	hl
;; b>r
		push 	de
;; ab>r
		push 	de
		push 	hl				
;; r>a
		pop 	hl
;; r>b
		pop 	de
;; r>ab
		pop 	hl				
		pop 	de

; ***************************************************************************************
;										Register to Register
; ***************************************************************************************

;; a>b 	
		ld 		d,h
		ld 		e,l
;; b>a
		ld 		h,d
		ld 		l,e
;; swap
		ex 		de,hl
;; param!
		ld 		(Parameter),hl

; ***************************************************************************************
;										Binary Operations
; ***************************************************************************************

;; add
		add 	hl,de

;; and
		ld 		a,h
		and 	d
		ld 		h,a
		ld 		a,l
		and 	e
		ld 		l,a

;; or 
		ld 		a,h
		or 		d
		ld 		h,a
		ld 		a,l
		or 		e
		ld 		l,a

;; xor
		ld 		a,h
		xor 	d
		ld 		h,a
		ld 		a,l
		xor 	e
		ld 		l,a

;; *+
		srl 	b 									; shift BC into C
		rr 		c
		jr 		nc,__SkipMultiply 					; if set, add B to A
		add 	hl,de
__SkipMultiply:
		ex 		de,hl 								; shift B left
		add 	hl,hl
		ex 		de,hl

;; =
		ld 		a,l 								; L = L ^ E
		xor 	e
		ld 		l,a
		ld 		a,h 								; A = H^D | L^E. 0 if equal.
		xor 	d
		or 		l
		jr 		z,__IsEqual
		ld 		a,$FF 	
__IsEqual:	 										; 0 if equal, $FF if different
		cpl 										; $FF if equal 0 if different
		ld 		h,a 								; put into HL
		ld 		l,a


;; <
		ld 		a,h 								; check bit 7 different.
		xor 	d
		add 	a,a 								; put into Carry flag
		jr 		c,__less_differentsigns 			; true if different signs.
		ex 		de,hl 								; HL = B, DE = A
		sbc 	hl,de 								; B - A, CS if -ve
		ld 		a,0 								; A = $00
		sbc 	a,a 								; A = $FF if Carry Set.
		add 	hl,de 								; fix DE back up
		ex 		de,hl
		jr 		__less_exit

__less_differentsigns:
		ld 		a,h 								; if H is +ve, then B must be < A
		add 	a,a 								; so carry set = true
		ld 		a,0 								; A = 0 if cc, 255 if cs
		sbc 	a,a 	
__less_exit:
		ld 		h,a 								; put result in HL
		ld 		l,a

; ***************************************************************************************
;										I/O Memory
; ***************************************************************************************

;; !
		ld 		(hl),e
		inc 	hl
		ld 		(hl),d
		dec 	hl

;; c!
		ld 		(hl),e

;; @ 	
		ld 		a,(hl)
		inc 	hl
		ld 		h,(hl)
		ld 		l,a

;; c@	
		ld 		l,(hl)
		ld 		h,0

;; +!
		ld 		a,(hl)
		add 	a,e
		ld 		(hl),a
		inc 	hl
		ld 		a,(hl)
		adc 	a,d
		ld 		(hl),a
		dec 	hl

;; p@	
		in 		l,(c)
		ld 		h,0

;; p! 	
		out 	(c),l

; ***************************************************************************************
;										Unary operations
; ***************************************************************************************

;; 0=
		ld 		a,h
		or 		l
		ld 		hl,$0000
		jr 		nz,__0Equal
		dec 	hl
__0Equal:

;; - 	
		ld 		a,h
		cpl
		ld 		h,a
		ld 		a,l
		cpl 		
		ld 		l,a

;; 2*
		add 	hl,hl
;; 4*
		add 	hl,hl		
		add 	hl,hl		
;; 8*
		add 	hl,hl		
		add 	hl,hl		
		add 	hl,hl		
;; 16*
		add 	hl,hl		
		add 	hl,hl		
		add 	hl,hl		
		add 	hl,hl		

;; 2/ 	
		srl 	h
		rr 		l

;; ++ 		
		inc 	hl
;; --
		dec 	hl
;; +++		
		inc 	hl
		inc 	hl
;; ---
		dec 	hl
		dec 	hl

;; negate
		ld 		a,h
		cpl
		ld 		h,a
		ld 		a,l
		cpl 		
		ld 		l,a
		inc 	hl

;; bswap
		ld 		a,h
		ld 		h,l
		ld 		l,a

; ***************************************************************************************
;											Miscellany
; ***************************************************************************************

;; copy
		ld 		bc,(Parameter)
		ldir 										; A = source B = target C = count

;; fill
		ld 		bc,(Parameter)
		ex 		de,hl  								; A = number B = target C = count
__fill_loop
		ld 		(hl),e		
		inc 	hl
		dec 	bc
		ld 		a,b
		or 		c
		jr 		nz,__fill_loop

;; ;
		ret

;; halt
		db 		$DD,$00 							; will cause CSpect to quit if -exit on CLI
__halt_loop:		
		di 
		halt 	
		jr 		__halt_loop


;; end_marker