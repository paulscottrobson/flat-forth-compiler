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
