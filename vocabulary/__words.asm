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
core_97_62_114:
		push 	hl
;; b>r
core_98_62_114:
		push 	de
;; ab>r
core_97_98_62_114:
		push 	de
		push 	hl
;; r>a
core_114_62_97:
		pop 	hl
;; r>b
core_114_62_98:
		pop 	de
;; r>ab
core_114_62_97_98:
		pop 	hl
		pop 	de

; ***************************************************************************************
;										Register to Register
; ***************************************************************************************

;; a>b
core_97_62_98:
		ld 		d,h
		ld 		e,l
;; b>a
core_98_62_97:
		ld 		h,d
		ld 		l,e
;; swap
core_115_119_97_112:
		ex 		de,hl
;; param!
core_112_97_114_97_109_33:
		ld 		(Parameter),hl

; ***************************************************************************************
;										Binary Operations
; ***************************************************************************************

;; add
core_97_100_100:
		add 	hl,de

;; and
core_97_110_100:
		ld 		a,h
		and 	d
		ld 		h,a
		ld 		a,l
		and 	e
		ld 		l,a

;; or
core_111_114:
		ld 		a,h
		or 		d
		ld 		h,a
		ld 		a,l
		or 		e
		ld 		l,a

;; xor
core_120_111_114:
		ld 		a,h
		xor 	d
		ld 		h,a
		ld 		a,l
		xor 	e
		ld 		l,a

;; *+
core_42_43:
		srl 	b 									; shift BC into C
		rr 		c
		jr 		nc,__SkipMultiply 					; if set, add B to A
		add 	hl,de
__SkipMultiply:
		ex 		de,hl 								; shift B left
		add 	hl,hl
		ex 		de,hl

;; =
core_61:
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
core_60:
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
core_33:
		ld 		(hl),e
		inc 	hl
		ld 		(hl),d
		dec 	hl

;; c!
core_99_33:
		ld 		(hl),e

;; @
core_64:
		ld 		a,(hl)
		inc 	hl
		ld 		h,(hl)
		ld 		l,a

;; c@
core_99_64:
		ld 		l,(hl)
		ld 		h,0

;; +!
core_43_33:
		ld 		a,(hl)
		add 	a,e
		ld 		(hl),a
		inc 	hl
		ld 		a,(hl)
		adc 	a,d
		ld 		(hl),a
		dec 	hl

;; p@
core_112_64:
		in 		l,(c)
		ld 		h,0

;; p!
core_112_33:
		out 	(c),l

; ***************************************************************************************
;										Unary operations
; ***************************************************************************************

;; 0=
core_48_61:
		ld 		a,h
		or 		l
		ld 		hl,$0000
		jr 		nz,__0Equal
		dec 	hl
__0Equal:

;; -
core_45:
		ld 		a,h
		cpl
		ld 		h,a
		ld 		a,l
		cpl
		ld 		l,a

;; 2*
core_50_42:
		add 	hl,hl
;; 4*
core_52_42:
		add 	hl,hl
		add 	hl,hl
;; 8*
core_56_42:
		add 	hl,hl
		add 	hl,hl
		add 	hl,hl
;; 16*
core_49_54_42:
		add 	hl,hl
		add 	hl,hl
		add 	hl,hl
		add 	hl,hl

;; 2/
core_50_47:
		srl 	h
		rr 		l

;; ++
core_43_43:
		inc 	hl
;; --
core_45_45:
		dec 	hl
;; +++
core_43_43_43:
		inc 	hl
		inc 	hl
;; ---
core_45_45_45:
		dec 	hl
		dec 	hl

;; negate
core_110_101_103_97_116_101:
		ld 		a,h
		cpl
		ld 		h,a
		ld 		a,l
		cpl
		ld 		l,a
		inc 	hl

;; bswap
core_98_115_119_97_112:
		ld 		a,h
		ld 		h,l
		ld 		l,a

; ***************************************************************************************
;											Miscellany
; ***************************************************************************************

;; copy
core_99_111_112_121:
		ld 		bc,(Parameter)
		ldir 										; A = source B = target C = count

;; fill
core_102_105_108_108:
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
core_59:
		ret

;; halt
core_104_97_108_116:
		db 		$DD,$00 							; will cause CSpect to quit if -exit on CLI
__halt_loop:
		di
		halt
		jr 		__halt_loop


;; end_marker
core_101_110_100_95_109_97_114_107_101_114:
