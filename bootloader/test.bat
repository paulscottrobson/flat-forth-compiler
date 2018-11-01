@echo off
call build.bat
rem
rem		Create a dummy boot.img file to run.
rem
python makesimpleimage.py
rem
rem		Run it
rem
if exist bootloader.sna	..\bin\CSpect.exe -zxnext -cur -brk  bootloader.sna

