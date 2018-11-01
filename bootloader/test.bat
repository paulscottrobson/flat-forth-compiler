@echo off
rem
rem		Test the boot read\write works
rem 
del /Q bootloader.sna 
del /Q boot_save.img
rem
rem		Create a dummy boot.img file large enough
rem
python makerandomimage.py
rem
rem		Assemble with testing on
rem
..\bin\snasm -d TESTRW bootloader.asm
del /Q bootloader.asm.dat
rem
rem		Run it
rem
if exist bootloader.sna	..\bin\CSpect.exe -zxnext -cur -brk -exit bootloader.sna
rem
rem		Check it was copied in and out successfully.
rem
if not exist boot_save.img goto exit
echo Comparing the input and output boot images now.
fc /b boot.img boot_save.img
:exit
del /Q boot.img 
del /Q boot_save.img


