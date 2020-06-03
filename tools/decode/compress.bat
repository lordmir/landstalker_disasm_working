@echo off
REM Landstalker Asset Compression
REM =============================
SETLOCAL
set PREFIX="D:\landstalker_disasm\disassembly\"
set SRC="assets_unpacked\"
set DST="assets_packed\"
set LZ77="tools\decode\lz77.exe"
goto :MAIN

:GETSIZE
set size=%~z1
EXIT /B %size%

:CHANGEEXT
set p=%~p1%~n1%2
EXIT /B 0

:EXTRACT_LZ77
echo ===== TESTING %1% =====
set FAIL=0
set IN=%PREFIX%%SRC%%1%
set IN=%IN:"=%
call :CHANGEEXT %IN% .bin
set IN=%p%
set OUT=%PREFIX%%DST%%1%
set OUT=%OUT:"=%
%LZ77% -cf "%IN%" extracted.bin
echo f | xcopy /y extracted.bin %OUT% > nul
EXIT /B 0

:MAIN
set FILES="graphics\static\lithograph\lithograph.lz77","graphics\static\islandmap\background.lz77","graphics\static\islandmap\foreground.lz77","graphics\static\ending\logos.lz77","graphics\static\hud\hudtiles.lz77","graphics\static\inventory\invtilemap.lz77","graphics\static\loadgame\chars.lz77","graphics\static\loadgame\tiles.lz77","graphics\static\logos\sega.lz77","graphics\static\logos\climax.lz77","graphics\static\titlescreen\title1.lz77","graphics\static\titlescreen\title2.lz77","graphics\static\titlescreen\title3.lz77","graphics\static\statuseffects\confusion1.lz77","graphics\static\statuseffects\confusion2.lz77","graphics\static\statuseffects\confusion3.lz77","graphics\static\statuseffects\confusion4.lz77","graphics\static\statuseffects\curse1.lz77","graphics\static\statuseffects\curse2.lz77","graphics\static\statuseffects\paralysis1.lz77","graphics\static\statuseffects\paralysis2.lz77","graphics\static\statuseffects\paralysis3.lz77","graphics\static\statuseffects\paralysis4.lz77","graphics\static\statuseffects\poison1.lz77","graphics\static\statuseffects\poison2.lz77","graphics\static\statuseffects\poison3.lz77","graphics\static\statuseffects\poison4.lz77","graphics\static\swordeffects\magic.lz77","graphics\static\swordeffects\thunder.lz77","graphics\static\swordeffects\ice.lz77","graphics\static\swordeffects\gaia.lz77","graphics\static\swordeffects\coinfall.lz77","graphics\fonts\credits.lz77","graphics\tilesets\tileset01.lz77","graphics\tilesets\tileset02.lz77","graphics\tilesets\tileset03.lz77","graphics\tilesets\tileset04.lz77","graphics\tilesets\tileset05.lz77","graphics\tilesets\tileset06.lz77","graphics\tilesets\tileset07.lz77","graphics\tilesets\tileset08.lz77","graphics\tilesets\tileset09.lz77","graphics\tilesets\tileset10.lz77","graphics\tilesets\tileset11.lz77","graphics\tilesets\tileset12.lz77","graphics\tilesets\tileset13.lz77","graphics\tilesets\tileset14.lz77","graphics\tilesets\tileset15.lz77","graphics\tilesets\tileset16.lz77","graphics\tilesets\tileset17.lz77","graphics\tilesets\tileset18.lz77"

(for %%i in (%FILES%) do (
	call :EXTRACT_LZ77 %%i
))

echo Extraction succeeded!

exit /B 0

:FAILURE

echo Test failed, quitting.
exit /B 1