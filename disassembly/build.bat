tools\build\asm68k.exe /p /o ae-,e+,w+,c+,op+,os+,ow+,oz+,l_ /e EXPANDED=0 landstalker.asm,landstalker.bin
tools\build\fix_checksum.py landstalker.bin
fc /b landstalker.bin ..\landstalker.bin
pause
