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

