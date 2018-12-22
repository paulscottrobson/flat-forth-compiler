@echo off
python ..\scripts\makecore.py core graphics.48k
..\bin\snasm __core.asm core.bin

