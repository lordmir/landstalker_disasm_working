tools\build\asm68k.exe /p /o ae-,e+,w+,c+,op+,os+,ow+,oz+,l_ /e EXPANDED=1 landstalker_expanded.asm,landstalker_expanded.bin
tools\build\fix_checksum.py landstalker_expanded.bin
pause
