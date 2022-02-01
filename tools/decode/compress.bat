@echo off
REM Landstalker Asset Compression
REM =============================
SETLOCAL ENABLEDELAYEDEXPANSION
set PREFIX=%~dp0
set SRC="assets_unpacked\"
set DST="assets_packed\"
set LZ77="tools\decode\lz77.exe"
set PAL2TPL="tools\decode\pal2tpl.exe"
set MAP2D="tools\decode\map2d.exe"
set MAP3D="tools\decode\map3d.exe"
set STRINGS="tools\decode\strings.exe"
goto :MAIN

:GETSIZE
set size=%~z1
EXIT /B %size%

:CHANGEEXT
set p=%~p1%~n1%2
EXIT /B 0

:GETPATH
set p="%~dp1"
EXIT /B 0

:EXTRACT_LZ77
echo ===== COMPRESSING %1% =====
set FAIL=0
set IN=%PREFIX%%SRC%%1%
set IN=%IN:"=%
call :CHANGEEXT %IN% .bin
set IN=%p%
set OUT=%PREFIX%%DST%%1%
set OUT=%OUT:"=%
%LZ77% -cf "%IN%" %TEMP%\extracted.bin
echo f | xcopy /y %TEMP%\extracted.bin %OUT% > nul
EXIT /B 0

:EXTRACT_TPL1
echo ===== COMPRESSING %1% =====
set FAIL=0
set IN=%PREFIX%%SRC%%1%
set IN=%IN:"=%
call :CHANGEEXT %IN% .tpl
set IN=%p%
set OUT=%PREFIX%%DST%%1%
set OUT=%OUT:"=%
set OPTS=%2
set OPTS=%OPTS:"=%
%PAL2TPL% -gf %OPTS% "%IN%" %TEMP%\extracted.pal
echo f | xcopy /y %TEMP%\extracted.pal %OUT% > nul
EXIT /B 0

:EXTRACT_MAP2D
echo ===== COMPRESSING %1% =====
set FAIL=0
set IN=%PREFIX%%SRC%%1%
set IN=%IN:"=%
set OUT=%PREFIX%%DST%%1%
set OUT=%OUT:"=%
call :CHANGEEXT %IN% .csv
set IN=%p%
set OPTS=%2
set OPTS=%OPTS:"=%
%MAP2D% -f -i csv -o %3 %OPTS% "%IN%" %TEMP%\extracted.%3
echo f | xcopy /y %TEMP%\extracted.%3 %OUT% > nul
EXIT /B 0

:EXTRACT_MAP3D
echo ===== COMPRESSING %1% =====
set FAIL=0
set IN=%PREFIX%%SRC%%1%
set IN=%IN:"=%
set OUT=%PREFIX%%DST%%1%.cmp
set OUT=%OUT:"=%
set OPTS=%2
set OPTS=%OPTS:"=%
%MAP3D% -f -c -b %IN%\background.csv -g %IN%\foreground.csv -m %IN%\heightmap.csv %OPTS% %TEMP%\extracted.cmp
echo f | xcopy /y %TEMP%\extracted.cmp %OUT% > nul
EXIT /B 0

:EXTRACT_STRINGS
echo ===== CONVERTING %1% =====
set FAIL=0
set IN=%PREFIX%%SRC%%1%
set IN=%IN:"=%
set OUT=%PREFIX%%DST%%1%
set OUT=%OUT:"=%
call :GETPATH %OUT%
set OUTPATH=%p%
mkdir %OUTPATH% > nul
set OUT=%OUTPATH%\%3
set OUT=%OUT:"=%
set OPTS=%2
set OPTS=%OPTS:"=%
%STRINGS% -f -c %OPTS% %IN% %OUT%
EXIT /B 0

:EXTRACT_COMPRESSED_STRINGS
echo ===== COMPRESSING %1% =====
set FAIL=0
set IN=%PREFIX%%SRC%%1%
set IN=%IN:"=%
set OUT=%PREFIX%%DST%%1%
set OUT=%OUT:"=%
call :GETPATH %OUT%
set OUTPATH=%p%
mkdir %OUTPATH% > nul
set OUT=%OUTPATH%\%3
set OUT=%OUT:"=%
set HUFFTABLE=%OUTPATH%\%4
set HUFFTABLE=%HUFFTABLE:"=%
set HUFFOFFSETS=%OUTPATH%\%5
set HUFFOFFSETS=%HUFFOFFSETS:"=%
set OPTS=%2
set OPTS=%OPTS:"=%
%STRINGS% -f -c %OPTS% -u %HUFFTABLE% -t %HUFFOFFSETS% %IN% %OUT%
EXIT /B 0

:MAIN

set LZ77_FILES="graphics\static\lithograph\lithograph.lz77","graphics\static\islandmap\background.lz77","graphics\static\islandmap\foreground.lz77","graphics\static\islandmap\dots.lz77","graphics\static\islandmap\friday.lz77","graphics\static\ending\logos.lz77","graphics\static\hud\hud.lz77","graphics\static\loadgame\chars.lz77","graphics\static\loadgame\tiles.lz77","graphics\static\logos\sega.lz77","graphics\static\logos\climax.lz77","graphics\static\titlescreen\title1.lz77","graphics\static\titlescreen\title2.lz77","graphics\static\titlescreen\title3.lz77","graphics\static\statuseffects\confusion1.lz77","graphics\static\statuseffects\confusion2.lz77","graphics\static\statuseffects\confusion3.lz77","graphics\static\statuseffects\confusion4.lz77","graphics\static\statuseffects\curse1.lz77","graphics\static\statuseffects\curse2.lz77","graphics\static\statuseffects\paralysis1.lz77","graphics\static\statuseffects\paralysis2.lz77","graphics\static\statuseffects\paralysis3.lz77","graphics\static\statuseffects\paralysis4.lz77","graphics\static\statuseffects\poison1.lz77","graphics\static\statuseffects\poison2.lz77","graphics\static\statuseffects\poison3.lz77","graphics\static\statuseffects\poison4.lz77","graphics\static\swordeffects\magic.lz77","graphics\static\swordeffects\thunder.lz77","graphics\static\swordeffects\ice.lz77","graphics\static\swordeffects\gaia.lz77","graphics\static\swordeffects\coinfall.lz77","graphics\fonts\credits.lz77","graphics\tilesets\tileset01.lz77","graphics\tilesets\tileset02.lz77","graphics\tilesets\tileset03.lz77","graphics\tilesets\tileset04.lz77","graphics\tilesets\tileset05.lz77","graphics\tilesets\tileset06.lz77","graphics\tilesets\tileset07.lz77","graphics\tilesets\tileset08.lz77","graphics\tilesets\tileset09.lz77","graphics\tilesets\tileset10.lz77","graphics\tilesets\tileset11.lz77","graphics\tilesets\tileset12.lz77","graphics\tilesets\tileset13.lz77","graphics\tilesets\tileset14.lz77","graphics\tilesets\tileset15.lz77","graphics\tilesets\tileset16.lz77","graphics\tilesets\tileset17.lz77","graphics\tilesets\tileset18.lz77"

set RLE_FILES="graphics\static\lithograph\lithograph.rle","graphics\static\ending\logos.rle","graphics\static\islandmap\foreground.rle","graphics\static\islandmap\background.rle","graphics\static\loadgame\tilemap.rle","graphics\static\logos\climax.rle","graphics\static\titlescreen\title1.rle","graphics\static\titlescreen\title2.rle","graphics\static\titlescreen\title3.rle"

set CBS_FILES="graphics\blocksets\blockset01_00.cbs","graphics\blocksets\blockset01_01.cbs","graphics\blocksets\blockset01_02.cbs","graphics\blocksets\blockset01_03.cbs","graphics\blocksets\blockset01_04.cbs","graphics\blocksets\blockset01_05.cbs","graphics\blocksets\blockset01_06.cbs","graphics\blocksets\blockset02_00.cbs","graphics\blocksets\blockset02_01.cbs","graphics\blocksets\blockset02_02.cbs","graphics\blocksets\blockset02_03.cbs","graphics\blocksets\blockset03_00.cbs","graphics\blocksets\blockset03_01.cbs","graphics\blocksets\blockset03_02.cbs","graphics\blocksets\blockset03_03.cbs","graphics\blocksets\blockset04_00.cbs","graphics\blocksets\blockset04_01.cbs","graphics\blocksets\blockset05_00.cbs","graphics\blocksets\blockset05_01.cbs","graphics\blocksets\blockset05_02.cbs","graphics\blocksets\blockset05_03.cbs","graphics\blocksets\blockset05_04.cbs","graphics\blocksets\blockset05_05.cbs","graphics\blocksets\blockset05_06.cbs","graphics\blocksets\blockset05_07.cbs","graphics\blocksets\blockset06_00.cbs","graphics\blocksets\blockset06_01.cbs","graphics\blocksets\blockset06_02.cbs","graphics\blocksets\blockset06_03.cbs","graphics\blocksets\blockset07_00.cbs","graphics\blocksets\blockset07_01.cbs","graphics\blocksets\blockset07_02.cbs","graphics\blocksets\blockset07_03.cbs","graphics\blocksets\blockset08_00.cbs","graphics\blocksets\blockset08_01.cbs","graphics\blocksets\blockset08_02.cbs","graphics\blocksets\blockset08_03.cbs","graphics\blocksets\blockset08_04.cbs","graphics\blocksets\blockset08_05.cbs","graphics\blocksets\blockset09_00.cbs","graphics\blocksets\blockset09_01.cbs","graphics\blocksets\blockset09_02.cbs","graphics\blocksets\blockset10_00.cbs","graphics\blocksets\blockset10_01.cbs","graphics\blocksets\blockset10_02.cbs","graphics\blocksets\blockset11_00.cbs","graphics\blocksets\blockset11_01.cbs","graphics\blocksets\blockset11_02.cbs","graphics\blocksets\blockset12_00.cbs","graphics\blocksets\blockset12_01.cbs","graphics\blocksets\blockset13_00.cbs","graphics\blocksets\blockset13_01.cbs","graphics\blocksets\blockset13_02.cbs","graphics\blocksets\blockset14_00.cbs","graphics\blocksets\blockset14_01.cbs","graphics\blocksets\blockset14_02.cbs","graphics\blocksets\blockset14_03.cbs","graphics\blocksets\blockset14_04.cbs","graphics\blocksets\blockset15_00.cbs","graphics\blocksets\blockset15_01.cbs","graphics\blocksets\blockset15_02.cbs","graphics\blocksets\blockset15_03.cbs","graphics\blocksets\blockset15_04.cbs","graphics\blocksets\blockset16_00.cbs","graphics\blocksets\blockset16_01.cbs","graphics\blocksets\blockset16_02.cbs","graphics\blocksets\blockset17_00.cbs","graphics\blocksets\blockset17_01.cbs","graphics\blocksets\blockset17_02.cbs","graphics\blocksets\blockset17_03.cbs","graphics\blocksets\blockset17_04.cbs","graphics\blocksets\blockset17_05.cbs","graphics\blocksets\blockset17_06.cbs","graphics\blocksets\blockset17_07.cbs","graphics\blocksets\blockset18_00.cbs","graphics\blocksets\blockset18_01.cbs","graphics\blocksets\blockset18_02.cbs","graphics\blocksets\blockset18_03.cbs","graphics\blocksets\blockset18_04.cbs","graphics\blocksets\blockset18_05.cbs","graphics\blocksets\blockset05_10.cbs","graphics\blocksets\blockset05_11.cbs","graphics\blocksets\blockset05_12.cbs","graphics\blocksets\blockset05_13.cbs","graphics\blocksets\blockset05_14.cbs","graphics\blocksets\blockset06_10.cbs","graphics\blocksets\blockset06_11.cbs","graphics\blocksets\blockset06_12.cbs","graphics\blocksets\blockset06_13.cbs","graphics\blocksets\blockset06_14.cbs","graphics\blocksets\blockset08_10.cbs","graphics\blocksets\blockset08_11.cbs","graphics\blocksets\blockset08_12.cbs","graphics\blocksets\blockset08_13.cbs","graphics\blocksets\blockset08_14.cbs","graphics\blocksets\blockset08_15.cbs","graphics\blocksets\blockset08_16.cbs","graphics\blocksets\blockset09_10.cbs","graphics\blocksets\blockset09_11.cbs","graphics\blocksets\blockset09_12.cbs","graphics\blocksets\blockset14_10.cbs","graphics\blocksets\blockset14_11.cbs","graphics\blocksets\blockset14_12.cbs","graphics\blocksets\blockset14_13.cbs","graphics\blocksets\blockset14_14.cbs","graphics\blocksets\blockset14_15.cbs","graphics\blocksets\blockset14_16.cbs","graphics\blocksets\blockset14_17.cbs","graphics\blocksets\blockset14_18.cbs","graphics\blocksets\blockset15_10.cbs","graphics\blocksets\blockset15_11.cbs","graphics\blocksets\blockset15_12.cbs","graphics\blocksets\blockset17_10.cbs","graphics\blocksets\blockset17_11.cbs","graphics\blocksets\blockset17_12.cbs"

set ROOM_PAL_PREFIX="graphics\roompalettes\pal"
set SPRITE_HI_PAL_PREFIX="graphics\spritepalettes\hi"
set SPRITE_LO_PAL_PREFIX="graphics\spritepalettes\lo"
set MAP_PREFIX="maps\map"

call :EXTRACT_MAP2D "graphics\static\hud\hudtilemap.map" "" "map" 
call :EXTRACT_MAP2D "graphics\static\inventory\invtilemap.lz77" "-l 80 -t 3" "lz77" 
call :EXTRACT_MAP2D "graphics\static\textbox\threelinetextbox.map" "" "map" 
call :EXTRACT_MAP2D "graphics\static\textbox\twolinetextbox.map" "" "map" 

call :EXTRACT_COMPRESSED_STRINGS "strings\main\strings.txt" "-x -p -r main" strings huffmantables.bin huffmancharoffsets.bin
call :EXTRACT_STRINGS "strings\names\characternames.txt" "-r names" characternames.bin
call :EXTRACT_STRINGS "strings\names\defaultname.txt" "-r names" defaultname.bin
call :EXTRACT_STRINGS "strings\names\itemnames.txt" "-r names" itemnames.bin
call :EXTRACT_STRINGS "strings\names\specialcharacternames.txt" "-r names" specialcharacternames.bin
call :EXTRACT_STRINGS "strings\names\system.txt" "-r names" system.bin
call :EXTRACT_STRINGS "strings\intro\intro.tsv" "-r intro -p" string
call :EXTRACT_STRINGS "strings\ending\credits.tsv" "-r ending" credits.bin

(for %%i in (%LZ77_FILES%) do (
	call :EXTRACT_LZ77 %%i ""
))

(for %%i in (%RLE_FILES%) do (
	call :EXTRACT_MAP2D %%i "" rle
))

(for %%i in (%CBS_FILES%) do (
	call :EXTRACT_MAP2D %%i "" cbs
))

REM Room Maps
(for /L %%i in (1,1,642) do (
    REM Add leading zeros
    set IDX=000%%i
    set IDX=!IDX:~-3!
    set FNAME=%MAP_PREFIX%!IDX!
    set FNAME=!FNAME:"=!
    call :EXTRACT_MAP3D !FNAME! ""
))

call :EXTRACT_TPL1 "graphics\static\ending\credits.pal" "-s 0 -l 4"
call :EXTRACT_TPL1 "graphics\static\inventory\inv1.pal" "-s 0 -l 8"
call :EXTRACT_TPL1 "graphics\static\inventory\invitemgreyedout.pal" ""
call :EXTRACT_TPL1 "graphics\static\inventory\invitempal.pal" ""
call :EXTRACT_TPL1 "graphics\static\islandmap\foreground.pal" ""
call :EXTRACT_TPL1 "graphics\static\islandmap\background.pal" ""
call :EXTRACT_TPL1 "graphics\static\lithograph\lithograph.pal" ""
call :EXTRACT_TPL1 "graphics\static\loadgame\loadgame.pal" ""
call :EXTRACT_TPL1 "graphics\static\loadgame\nigel.pal" ""
call :EXTRACT_TPL1 "graphics\static\logos\sega.pal" "-s 0 -l 7"
call :EXTRACT_TPL1 "graphics\static\logos\climax.pal" "-s 0 -l 4"
call :EXTRACT_TPL1 "graphics\static\titlescreen\blues.pal" "-z -s 0 -l 27"
call :EXTRACT_TPL1 "graphics\static\titlescreen\yellows.pal" "-s 0 -l 5"
call :EXTRACT_TPL1 "graphics\static\titlescreen\title3.pal" ""
call :EXTRACT_TPL1 "graphics\static\titlescreen\title3_highlight.pal" ""
call :EXTRACT_TPL1 "graphics\miscpalettes\defaultplayer.pal" ""
call :EXTRACT_TPL1 "graphics\miscpalettes\lavapalette.pal" ""
call :EXTRACT_TPL1 "graphics\miscpalettes\kazaltwarp.pal" "-s 13 -l 2 -c 9"
call :EXTRACT_TPL1 "graphics\miscpalettes\armourpalswaps.pal" "-s 11 -l 2 -c 5"
call :EXTRACT_TPL1 "graphics\miscpalettes\swordpalswaps.pal" "-s 13 -l 2 -c 6"
call :EXTRACT_TPL1 "graphics\static\hud\hud.pal" "-s 10 -l 5"
call :EXTRACT_TPL1 "graphics\miscpalettes\labrynthlit.pal" "-s 2 -l 13" 
call :EXTRACT_TPL1 "graphics\spritepalettes\projectile1.pal" "-s 8 -l 2 -c 3"
call :EXTRACT_TPL1 "graphics\spritepalettes\projectile2.pal" "-s 8 -l 2 -c 2" 


REM Room Palettes
(for /L %%i in (1,1,54) do (
    REM Add leading zeros
    set IDX=000%%i
    set IDX=!IDX:~-3!
    set FNAME=%ROOM_PAL_PREFIX%!IDX!.pal
    set FNAME=!FNAME:"=!
    call :EXTRACT_TPL1 !FNAME! "-s 2 -l 13"
))

REM Sprite Hi Palettes
(for /L %%i in (1,1,17) do (
    REM Add leading zeros
    set IDX=000%%i
    set IDX=!IDX:~-3!
    set FNAME=%SPRITE_HI_PAL_PREFIX%!IDX!.pal
    set FNAME=!FNAME:"=!
    call :EXTRACT_TPL1 !FNAME! "-s 8 -l 7"
))

REM Sprite Lo Palettes
(for /L %%i in (1,1,80) do (
    REM Add leading zeros
    set IDX=000%%i
    set IDX=!IDX:~-3!
    set FNAME=%SPRITE_LO_PAL_PREFIX%!IDX!.pal
    set FNAME=!FNAME:"=!
    call :EXTRACT_TPL1 !FNAME! "-s 2 -l 6"
))

echo Compression succeeded!

exit /B 0

:FAILURE

echo Test failed, quitting.
exit /B 1