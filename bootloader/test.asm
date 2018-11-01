;
;	This is a wrapper for bootloader.asm defining TESTRW, because zasm does not (surprisingly) allowe
; 	you to do this via the command line.
;	

#define TESTRW 1
	include "bootloader.asm"

	