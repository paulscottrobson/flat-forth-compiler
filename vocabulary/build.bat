@echo off
python ..\scripts\processcore.py
..\bin\snasm -vice __words.asm core.bin
python ..\scripts\makecorelibrary.py
copy corewords.py ..\scripts
