; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		kernel.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		22nd December 2018
;		Purpose :	Flat Color Forth Kernel
;
; ***************************************************************************************
; ***************************************************************************************

StackTop = $7EFC 									;      -$7EFC Top of stack

		opt 	zxnextreg
		org 	$8000 								; $8000 boot.
		jr 		Boot
		org 	$8004 								; $8004 address of sysinfo
		dw 		SystemInformation
		org 	$8008 								; $8008 3rd parameter register
		dw 		0,0
		org 	$8010 								; $8010 address of words list.
		dw 	 	WordListAddress,0


Boot:	ld 		sp,StackTop							; reset Z80 Stack
		di											; disable interrupts

		db 		$ED,$91,7,2							; set turbo port (7) to 2 (14Mhz speed)

AlternateFont:										; nicer font
		include "font.inc" 							; can be $3D00 here to save memory

; *********************************************************************************
; *********************************************************************************
;
;		File:		keyboard.asm
;		Purpose:	Spectrum Keyboard Interface
;		Date : 		22nd December 2018
;		Author:		paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;
;			Scan the keyboard, return currently pressed key code in A
;
; *********************************************************************************

external_0:
;; inkey
		ex 		de,hl
		call 	IOScanKeyboard
		ld 		l,a
		ld 		h,0
		ret

IOScanKeyboard:
		push 	bc
		push 	de
		push 	hl

		ld 		hl,__kr_no_shift_table 				; firstly identify shift state.

		ld 		c,$FE 								; check CAPS SHIFT (emulator : left shift)
		ld 		b,$FE
		in 		a,(c)
		bit 	0,a
		jr 		nz,__kr1
		ld 		hl,__kr_shift_table
		jr 		__kr2
__kr1:
		ld 		b,$7F 								; check SYMBOL SHIFT (emulator : right shift)
		in 		a,(c)
		bit 	1,a
		jr 		nz,__kr2
		ld 		hl,__kr_symbol_shift_table
__kr2:

		ld 		e,$FE 								; scan pattern.
__kr3:	ld 		a,e 								; work out the mask, so we don't detect shift keys
		ld 		d,$1E 								; $FE row, don't check the least significant bit.
		cp 		$FE
		jr 		z,___kr4
		ld 		d,$01D 								; $7F row, don't check the 2nd least significant bit
		cp 		$7F
		jr 		z,___kr4
		ld 		d,$01F 								; check all bits.
___kr4:
		ld 		b,e 								; scan the keyboard
		ld 		c,$FE
		in 		a,(c)
		cpl 										; make that active high.
		and 	d  									; and with check value.
		jr 		nz,__kr_keypressed 					; exit loop if key pressed.

		inc 	hl 									; next set of keyboard characters
		inc 	hl
		inc 	hl
		inc 	hl
		inc 	hl

		ld 		a,e 								; get pattern
		add 	a,a 								; shift left
		or 		1 									; set bit 1.
		ld 		e,a

		cp 		$FF 								; finished when all 1's.
		jr 		nz,__kr3
		xor 	a
		jr 		__kr_exit 							; no key found, return with zero.
;
__kr_keypressed:
		inc 	hl  								; shift right until carry set
		rra
		jr 		nc,__kr_keypressed
		dec 	hl 									; undo the last inc hl
		ld 		a,(hl) 								; get the character number.
__kr_exit:
		pop 	hl
		pop 	de
		pop 	bc
		ret

; *********************************************************************************
;	 						Keyboard Mapping Tables
; *********************************************************************************
;
;	$FEFE-$7FFE scan, bit 0-4, active low
;
;	3:Abort (Shift+Q) 8:Backspace 13:Return
;	27:Break 32-127: Std ASCII all L/C
;
__kr_no_shift_table:
		db 		0,  'z','x','c','v',			'a','s','d','f','g'
		db 		'q','w','e','r','t',			'1','2','3','4','5'
		db 		'0','9','8','7','6',			'p','o','i','u','y'
		db 		13, 'l','k','j','h',			' ', 0, 'm','n','b'

__kr_shift_table:
__kr_symbol_shift_table:
		db 		 0, ':', 0,  '?','/',			'~','|','\','{','}'
		db 		 3,  0,  0  ,'<','>',			'!','@','#','$','%'
		db 		'_',')','(',"'",'&',			'"',';', 0, ']','['
		db 		27, '=','+','-','^',			' ', 0, '.',',','*'

		db 		0,  ':',0  ,'?','/',			'~','|','\','{','}'
		db 		3,  0,  0  ,'<','>',			16,17,18,19,20
		db 		8, ')',23,  22, 21,				'"',';', 0, ']','['
		db 		27, '=','+','-','^',			' ', 0, '.',',','*'
; *********************************************************************************
; *********************************************************************************
;
;		File:		screen48k.asm
;		Purpose:	Hardware interface to Spectrum display, standard but with
;					sprites enabled.
;		Date : 		22nd December 2018
;		Author:		paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;
;						Call the SetMode for the Spectrum 48k
;
; *********************************************************************************

GFXInitialise:
		push 	af 									; save registers
		push 	bc

		ld 		bc,$123B 							; Layer 2 access port
		ld 		a,0 								; disable Layer 2
		out 	(c),a
		db 		$ED,$91,$15,$3						; Disable LowRes but enable Sprites

		ld 		hl,$4000 							; clear pixel memory
__cs1:	ld 		(hl),0
		inc 	hl
		ld 		a,h
		cp 		$58
		jr 		nz,__cs1
__cs2:	ld 		(hl),$47							; clear attribute memory
		inc 	hl
		ld 		a,h
		cp 		$5B
		jr 		nz,__cs2
		xor 	a 									; border off
		out 	($FE),a
		pop 	bc
		pop 	af
		ld 		hl,$1820 							; H = 24,L = 32, screen extent
		ret

; *********************************************************************************
;
;				Write a character E on the screen at HL, in colour D
;
; *********************************************************************************

GFXCharacterHandler:
		push 	af 									; save registers
		push 	bc
		push 	de
		push 	hl

		ld 		b,e 								; character in B
		ld 		a,h 								; check range.
		cp 		3
		jr 		nc,__ZXWCExit
;
;		work out attribute position
;
		push 	hl 									; save position.
		ld 		a,h
		add 	$58
		ld 		h,a

		ld 		a,d 								; get current colour
		and 	7  									; mask 0..2
		or 		$40  								; make bright
		ld 		(hl),a 								; store it.
		pop 	hl
;
;		calculate screen position => HL
;
		push 	de
		ex 		de,hl
		ld 		l,e 								; Y5 Y4 Y3 X4 X3 X2 X1 X0
		ld 		a,d
		and 	3
		add 	a,a
		add 	a,a
		add 	a,a
		or 		$40
		ld 		h,a
		pop 	de
;
;		char# 32-127 to font address => DE
;
		ld 		a,b 								; get character
		call 	GFXGetFontGraphicDE
;
;		copy font data to screen position.
;
		ld 		a,b
		ld 		b,8 								; copy 8 characters
		ld 		c,0 								; XOR value 0
__ZXWCCopy:
		ld 		a,(de)								; get font data
		ld 		(hl),a 								; write back
		inc 	h 									; bump pointers
		inc 	de
		djnz 	__ZXWCCopy 							; do B times.
__ZXWCExit:
		pop 	hl 									; restore and exit
		pop 	de
		pop 	bc
		pop 	af
		ret

; *********************************************************************************
; *********************************************************************************
;
;		File:		graphics.asm
;		Purpose:	General screen I/O routines
;		Date : 		22nd December 2018
;		Author:		paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;
;							Clear or Reset Display
;
; *********************************************************************************

external_1:
;; screen.clear

GFXInitialiseDisplay
		push 	bc
		push 	de
		push 	hl
		call 	GFXInitialise
		ld 		a,l 								; save screen extent
		ld 		(__DIScreenWidth),a
		ld 		a,h
		ld 		(__DIScreenHeight),a
		pop 	hl
		pop 	de
		pop 	bc
		ret

; *********************************************************************************
;
;		Write character D (colour) E (character) to position HL.
;
; *********************************************************************************

external_2:
;; screen!

GFXWriteCharacter:
		push 	af
		push 	bc
		push 	de
		push 	hl
		call	GFXCharacterHandler
		pop 	hl
		pop 	de
		pop 	bc
		pop 	af
		ret

; *********************************************************************************
;
;						Write hex word DE at position HL
;
; *********************************************************************************

external_3:
;; screen.hex!

GFXWriteHexWord:
		ld 		a,6
GFXWriteHexWordA:
		push 	bc
		push 	de
		push 	hl
		ld 		c,a
		ld 		a,d
		push 	de
		call 	__GFXWHByte
		pop 	de
		ld 		a,e
		call	__GFXWHByte
		pop 	hl
		pop 	de
		pop 	bc
		ret

__GFXWHByte:
		push 	af
		rrc 	a
		rrc		a
		rrc 	a
		rrc 	a
		call 	__GFXWHNibble
		pop 	af
__GFXWHNibble:
		ld 		d,c
		and 	15
		cp 		10
		jr 		c,__GFXWHDigit
		add		a,7
__GFXWHDigit:
		add 	a,48
		ld 		e,a
		call 	GFXWriteCharacter
		inc 	hl
		ret

; *********************************************************************************
;
;				For character A, put address of character in DE
;
; *********************************************************************************

GFXGetFontGraphicDE:
		push 	af
		push 	bc
		push 	hl
		and 	$7F 								; bits 0-6 only.
		sub 	32
		ld 		l,a 								; put in HL
		ld 		h,0
		add 	hl,hl 								; x 8
		add 	hl,hl
		add 	hl,hl
		ld 		de,(__DIFontBase) 					; add the font base.
		add 	hl,de
		ex 		de,hl 								; put in DE (font address)
		pop 	hl
		pop 	bc
		pop 	af
		cp 		$7F
		ret 	nz
		ld 		de,__GFXPromptCharacter
		ret

__GFXPromptCharacter:
		db 		$FC,$7E,$3F,$1F
		db 		$1F,$3F,$7E,$FC


; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		data.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		22nd December 2018
;		Purpose :	Data area
;
; ***************************************************************************************
; ***************************************************************************************

; ***************************************************************************************
;
;								System Information
;
; ***************************************************************************************

SystemInformation:

Here:												; +0 	Here
		dw 		FreeMemory
HerePage: 											; +2	Here.Page
		db 		$20,0
NextFreePage: 										; +4 	Next available code page (2 8k pages/page)
		db 		$22,0,0,0
DisplayInfo: 										; +8 	Display information
		dw 		DisplayInformation,0
Parameter: 											; +12 	Third Parameter used in some functions.
		dw 		0,0

; ***************************************************************************************
;
;							 Display system information
;
; ***************************************************************************************

DisplayInformation:

__DIScreenWidth: 									; +0 	screen width
		db 		0,0,0,0
__DIScreenHeight:									; +4 	screen height
		db 		0,0,0,0
__DIFontBase:										; font in use
		dw 		AlternateFont

; ***************************************************************************************
;
;						  The word list address goes here.
;
; ***************************************************************************************

WordListAddress:
		include "__externals.inc"					; auto generated

FreeMemory:
		org 	$C000
		db 		0 									; start of dictionary, which is empty.
