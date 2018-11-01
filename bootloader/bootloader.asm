; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		bootloader.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		21st October
;		Purpose :	Boot-Loads code by loading "boot.img" into memory
;					from $8000-$BFFF then banks 32-94 (2 per page) into $C000-$FFFF
;
;					Also provides write back facility through vectors at $7FFD (write to
;	 				boot_save.img) and $7FFD (write expecting ASCIIZ filename in IX)
;
; ***************************************************************************************
; ***************************************************************************************

FirstPage = 32 												; these are the pages for an 
LastPage = 95 												; unexpanded ZXNext

;		org 	$4000-27 									; .SNA file if not using SNASM
;		db 		$3F
;		dw 		0,0,0,0,0,0,0,0,0,0,0
;		org 	$4000-4
;		dw 		$5AFE
;		db 		1
;		db 		7

		opt 	zxnextreg
		org 	$5AFE
		dw 		$7F00	
		org 	$7F00 							

Start:	ld 		sp,Start-1 									; set up the stack.
		;db 	$DD,$01
		ifdef	TESTRW
		jp 		TestIOCopy 									; run test program ?
		endif
		ld 		ix,ImageName 								; read the image into memory
		call 	ReadNextMemory
		jp	 	$8000 										; run.

; ***************************************************************************************
;
;		This test program loads in boot.img but writes out to boot_save.img
;		So we can check the read/write works.
;
; ***************************************************************************************

TestIOCopy:
		;db 		$DD,$01
		ld 		ix,ImageName 								; read in boot.img
		call 	ReadNextMemory
		ld 		ix,ImageName2								; write out boot_save.img
		call 	WriteNextMemory
		ld 		a,2 										; make border red to show success
		out 	($FE),a
stop:	jr 		stop 

; ***************************************************************************************
;
;								 Access the default drive
;
; ***************************************************************************************

FindDefaultDrive:
		rst 	$08 										; set the default drive.
		db 		$89
		ld 		(DefaultDrive),a
		ret

; ***************************************************************************************
;
;			Read ZXNext memory from $8000-$BFFF then pages from $C000-$FFFF
;
; ***************************************************************************************

ReadNextMemory:
		call 	FindDefaultDrive 							; get default drive
		call 	OpenFileRead 								; open for reading
		ld 		ix,$8000 									; read in 8000-BFFF
		call 	Read16kBlock
		ld 		b,FirstPage 								; current page
__ReadBlockLoop:
		call 	SetPaging 									; access the pages
		ld 		ix,$C000 									; read in C000-FFFF
		call 	Read16kBlock 								; read it in
		inc 	b 											; there are two 8k blocks
		inc 	b 											; per page
		ld 		a,b
		cp 		LastPage+1 									; until read in pages 32-95
		jr 		nz,__ReadBlockLoop
		call 	CloseFile 									; close file.
		ret

; ***************************************************************************************
;
;			Write ZXNext memory from $8000-$BFFF then pages from $C000-$FFFF
;
; ***************************************************************************************

WriteNextMemory:
		call 	FindDefaultDrive 							; get default drive
		call 	OpenFileWrite 								; open for writing
		ld 		ix,$8000  									; write $8000-$BFFF
		call 	Write16kBlock
		ld 		b,FirstPage
__WriteBlockLoop:
		call 	SetPaging 									; select page
		ld 		ix,$C000 									; write block out
		call 	Write16kBlock
		inc 	b 											; skip forward 2 blocks
		inc 	b
		ld 		a,b 										; until memory all written out.
		cp 		LastPage+1
		jr 		nz,__WriteBlockLoop
		call 	CloseFile 									; close file
		ret

; ***************************************************************************************
;
;						   Map $C000-$FFFF onto blocks b and b+1
;
; ***************************************************************************************

SetPaging:
		ld 		a,b 										; set $56
		db 		$ED,$92,$56
		inc 	a 											; set $57
		db 		$ED,$92,$57
		ret


; ***************************************************************************************
;
;									Open file write
;
; ***************************************************************************************

OpenFileWrite:
		push 	af
		push 	bc
		push 	ix
		ld 		b,12
		jr 		__OpenFile

; ***************************************************************************************
;
;									Open file rea;
; ***************************************************************************************

OpenFileRead:
		push 	af
		push 	bc
		push 	ix
		ld 		b,1
__OpenFile:
		ld 		a,(DefaultDrive)
		rst 	$08
		db 		$9A
		ld 		(FileHandle),a 
		pop 	ix
		pop 	bc
		pop 	af
		ret

; ***************************************************************************************
;
;									Read 16k block
;
; ***************************************************************************************

Read16kBlock:
		push 	af
		push 	bc
		push 	ix
		ld 		a,(FileHandle)
		ld 		bc,$4000
		rst 	$08
		db 		$9D
		pop 	ix
		pop 	bc
		pop 	af
		ret

; ***************************************************************************************
;
;									Write 16k block
;
; ***************************************************************************************

Write16kBlock:
		push 	af
		push 	bc
		push 	ix
		ld 		a,(FileHandle)
		ld 		bc,$4000
		rst 	$08
		db 		$9E
		pop 	ix
		pop 	bc
		pop 	af
		ret

; ***************************************************************************************
;
;										Close open file
;
; ***************************************************************************************

CloseFile:
		push 	af
		ld 		a,(FileHandle)
		rst 	$08
		db 		$9B
		pop 	af
		ret		

ImageName:
		db 		"boot.img",0
ImageName2:
		db 		"boot_save.img",0

DefaultDrive:
		db 		0
FileHandle:
		db 		0

; ***************************************************************************************
;
;								 These functions live here
;
; ***************************************************************************************

		org 	$7FF9
		ld 		ix,ImageName2
		jp 		WriteNextMemory

;		org 	$FFFF
;		db 		0

		savesna "bootloader.sna",Start
