@echo off
rem
rem	Remove SNA files
rem
del /Q bootloader.sna 
del /Q ..\files\bootloader.sna
rem
rem	Build SNA file
rem
..\bin\snasm bootloader.asm
del /Q bootloader.asm.dat
rem
rem	Copy to files area if successful.
rem
if exist bootloader.sna	copy bootloader.sna ..\files >NUL


