@echo off
REM Landstalker Asset Expansion
REM ===========================
SETLOCAL ENABLEDELAYEDEXPANSION
set PREFIX=%~dp0
set SRC="assets_packed\"
set DST="assets_unpacked\"
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
echo ===== EXTRACTING %1% =====
set FAIL=0
set IN=%PREFIX%%SRC%%1%
set IN=%IN:"=%
set OUT=%PREFIX%%DST%%1%
set OUT=%OUT:"=%
call :CHANGEEXT %OUT% .bin
set OUT=%p%
%LZ77% -df "%IN%" %TEMP%\extracted.bin
echo f | xcopy /y %TEMP%\extracted.bin %OUT% > nul
EXIT /B 0

:EXTRACT_TPL1
echo ===== EXTRACTING %1% =====
set FAIL=0
set IN=%PREFIX%%SRC%%1%
set IN=%IN:"=%
set OUT=%PREFIX%%DST%%1%
set OUT=%OUT:"=%
call :CHANGEEXT %OUT% .tpl
set OUT=%p%
set OPTS=%2
set OPTS=%OPTS:"=%
%PAL2TPL% -tf %OPTS% "%IN%" %TEMP%\extracted.tpl
echo f | xcopy /y %TEMP%\extracted.tpl %OUT% > nul
EXIT /B 0

:EXTRACT_MAP2D
echo ===== EXTRACTING %1% =====
set FAIL=0
set IN=%PREFIX%%SRC%%1%
set IN=%IN:"=%
set OUT=%PREFIX%%DST%%1%
set OUT=%OUT:"=%
call :CHANGEEXT %OUT% .csv
set OUT=%p%
set OPTS=%2
set OPTS=%OPTS:"=%
%MAP2D% -f -i %3 -o csv %OPTS% "%IN%" %TEMP%\extracted.csv
echo f | xcopy /y %TEMP%\extracted.csv %OUT% > nul
EXIT /B 0

:EXTRACT_MAP3D
echo ===== EXPANDING %1% =====
set FAIL=0
set IN=%PREFIX%%SRC%%1%.cmp
set IN=%IN:"=%
set OUT=%PREFIX%%DST%%1%
set OUT=%OUT:"=%
set OPTS=%2
set OPTS=%OPTS:"=%
%MAP3D% -f -d -b %TEMP%\background.csv -g %TEMP%\foreground.csv -m %TEMP%\heightmap.csv %OPTS% %IN%
echo f | xcopy /y %TEMP%\background.csv %OUT%\ > nul
echo f | xcopy /y %TEMP%\foreground.csv %OUT%\ > nul
echo f | xcopy /y %TEMP%\heightmap.csv %OUT%\ > nul
EXIT /B 0

:EXTRACT_STRINGS
echo ===== EXPANDING %1% =====
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
%STRINGS% -f -e %OPTS% %IN% %OUT%
EXIT /B 0

:EXTRACT_COMPRESSED_STRINGS
echo ===== DECOMPRESSING %1% =====
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
call :GETPATH %IN%
set INPATH=%p%
set HUFFTABLE=%INPATH%\%4
set HUFFTABLE=%HUFFTABLE:"=%
set HUFFOFFSETS=%INPATH%\%5
set HUFFOFFSETS=%HUFFOFFSETS:"=%
set OPTS=%2
set OPTS=%OPTS:"=%
%STRINGS% -f -e %OPTS% -u %HUFFTABLE% -t %HUFFOFFSETS% %IN% %OUT%
EXIT /B 0

:MAIN
set LZ77_FILES="graphics\static\lithograph\lithograph.lz77","graphics\static\islandmap\background.lz77","graphics\static\islandmap\foreground.lz77","graphics\static\islandmap\dots.lz77","graphics\static\islandmap\friday.lz77","graphics\static\ending\logos.lz77","graphics\static\hud\hud.lz77","graphics\static\loadgame\chars.lz77","graphics\static\loadgame\tiles.lz77","graphics\static\logos\sega.lz77","graphics\static\logos\climax.lz77","graphics\static\titlescreen\title1.lz77","graphics\static\titlescreen\title2.lz77","graphics\static\titlescreen\title3.lz77","graphics\static\statuseffects\confusion1.lz77","graphics\static\statuseffects\confusion2.lz77","graphics\static\statuseffects\confusion3.lz77","graphics\static\statuseffects\confusion4.lz77","graphics\static\statuseffects\curse1.lz77","graphics\static\statuseffects\curse2.lz77","graphics\static\statuseffects\paralysis1.lz77","graphics\static\statuseffects\paralysis2.lz77","graphics\static\statuseffects\paralysis3.lz77","graphics\static\statuseffects\paralysis4.lz77","graphics\static\statuseffects\poison1.lz77","graphics\static\statuseffects\poison2.lz77","graphics\static\statuseffects\poison3.lz77","graphics\static\statuseffects\poison4.lz77","graphics\static\swordeffects\magic.lz77","graphics\static\swordeffects\thunder.lz77","graphics\static\swordeffects\ice.lz77","graphics\static\swordeffects\gaia.lz77","graphics\static\swordeffects\coinfall.lz77","graphics\fonts\credits.lz77","graphics\tilesets\tileset01.lz77","graphics\tilesets\tileset02.lz77","graphics\tilesets\tileset03.lz77","graphics\tilesets\tileset04.lz77","graphics\tilesets\tileset05.lz77","graphics\tilesets\tileset06.lz77","graphics\tilesets\tileset07.lz77","graphics\tilesets\tileset08.lz77","graphics\tilesets\tileset09.lz77","graphics\tilesets\tileset10.lz77","graphics\tilesets\tileset11.lz77","graphics\tilesets\tileset12.lz77","graphics\tilesets\tileset13.lz77","graphics\tilesets\tileset14.lz77","graphics\tilesets\tileset15.lz77","graphics\tilesets\tileset16.lz77","graphics\tilesets\tileset17.lz77","graphics\tilesets\tileset18.lz77"

set RLE_FILES="graphics\static\lithograph\lithograph.rle","graphics\static\ending\logos.rle","graphics\static\islandmap\foreground.rle","graphics\static\islandmap\background.rle","graphics\static\loadgame\tilemap.rle","graphics\static\logos\climax.rle","graphics\static\titlescreen\title1.rle","graphics\static\titlescreen\title2.rle","graphics\static\titlescreen\title3.rle"

set CBS_FILES="graphics\blocksets\blockset1_0.cbs","graphics\blocksets\blockset1_1.cbs","graphics\blocksets\blockset1_2.cbs","graphics\blocksets\blockset1_3.cbs","graphics\blocksets\blockset1_4.cbs","graphics\blocksets\blockset1_5.cbs","graphics\blocksets\blockset1_6.cbs","graphics\blocksets\blockset2_0.cbs","graphics\blocksets\blockset2_1.cbs","graphics\blocksets\blockset2_2.cbs","graphics\blocksets\blockset2_3.cbs","graphics\blocksets\blockset3_0.cbs","graphics\blocksets\blockset3_1.cbs","graphics\blocksets\blockset3_2.cbs","graphics\blocksets\blockset3_3.cbs","graphics\blocksets\blockset4_0.cbs","graphics\blocksets\blockset4_1.cbs","graphics\blocksets\blockset5_0.cbs","graphics\blocksets\blockset5_1.cbs","graphics\blocksets\blockset5_2.cbs","graphics\blocksets\blockset5_3.cbs","graphics\blocksets\blockset5_4.cbs","graphics\blocksets\blockset5_5.cbs","graphics\blocksets\blockset5_6.cbs","graphics\blocksets\blockset5_7.cbs","graphics\blocksets\blockset6_0.cbs","graphics\blocksets\blockset6_1.cbs","graphics\blocksets\blockset6_2.cbs","graphics\blocksets\blockset6_3.cbs","graphics\blocksets\blockset7_0.cbs","graphics\blocksets\blockset7_1.cbs","graphics\blocksets\blockset7_2.cbs","graphics\blocksets\blockset7_3.cbs","graphics\blocksets\blockset8_0.cbs","graphics\blocksets\blockset8_1.cbs","graphics\blocksets\blockset8_2.cbs","graphics\blocksets\blockset8_3.cbs","graphics\blocksets\blockset8_4.cbs","graphics\blocksets\blockset8_5.cbs","graphics\blocksets\blockset9_0.cbs","graphics\blocksets\blockset9_1.cbs","graphics\blocksets\blockset9_2.cbs","graphics\blocksets\blockset10_0.cbs","graphics\blocksets\blockset10_1.cbs","graphics\blocksets\blockset10_2.cbs","graphics\blocksets\blockset11_0.cbs","graphics\blocksets\blockset11_1.cbs","graphics\blocksets\blockset11_2.cbs","graphics\blocksets\blockset12_0.cbs","graphics\blocksets\blockset12_1.cbs","graphics\blocksets\blockset13_0.cbs","graphics\blocksets\blockset13_1.cbs","graphics\blocksets\blockset13_2.cbs","graphics\blocksets\blockset14_0.cbs","graphics\blocksets\blockset14_1.cbs","graphics\blocksets\blockset14_2.cbs","graphics\blocksets\blockset14_3.cbs","graphics\blocksets\blockset14_4.cbs","graphics\blocksets\blockset15_0.cbs","graphics\blocksets\blockset15_1.cbs","graphics\blocksets\blockset15_2.cbs","graphics\blocksets\blockset15_3.cbs","graphics\blocksets\blockset15_4.cbs","graphics\blocksets\blockset16_0.cbs","graphics\blocksets\blockset16_1.cbs","graphics\blocksets\blockset16_2.cbs","graphics\blocksets\blockset17_0.cbs","graphics\blocksets\blockset17_1.cbs","graphics\blocksets\blockset17_2.cbs","graphics\blocksets\blockset17_3.cbs","graphics\blocksets\blockset17_4.cbs","graphics\blocksets\blockset17_5.cbs","graphics\blocksets\blockset17_6.cbs","graphics\blocksets\blockset17_7.cbs","graphics\blocksets\blockset18_0.cbs","graphics\blocksets\blockset18_1.cbs","graphics\blocksets\blockset18_2.cbs","graphics\blocksets\blockset18_3.cbs","graphics\blocksets\blockset18_4.cbs","graphics\blocksets\blockset18_5.cbs","graphics\blocksets\blockset19_0.cbs","graphics\blocksets\blockset19_1.cbs","graphics\blocksets\blockset19_2.cbs","graphics\blocksets\blockset19_3.cbs","graphics\blocksets\blockset19_4.cbs","graphics\blocksets\blockset20_0.cbs","graphics\blocksets\blockset20_1.cbs","graphics\blocksets\blockset20_2.cbs","graphics\blocksets\blockset20_3.cbs","graphics\blocksets\blockset20_4.cbs","graphics\blocksets\blockset21_0.cbs","graphics\blocksets\blockset21_1.cbs","graphics\blocksets\blockset21_2.cbs","graphics\blocksets\blockset21_3.cbs","graphics\blocksets\blockset21_4.cbs","graphics\blocksets\blockset21_5.cbs","graphics\blocksets\blockset21_6.cbs","graphics\blocksets\blockset22_0.cbs","graphics\blocksets\blockset22_1.cbs","graphics\blocksets\blockset22_2.cbs","graphics\blocksets\blockset23_0.cbs","graphics\blocksets\blockset23_1.cbs","graphics\blocksets\blockset23_2.cbs","graphics\blocksets\blockset23_3.cbs","graphics\blocksets\blockset23_4.cbs","graphics\blocksets\blockset23_5.cbs","graphics\blocksets\blockset23_6.cbs","graphics\blocksets\blockset23_7.cbs","graphics\blocksets\blockset23_8.cbs","graphics\blocksets\blockset24_0.cbs","graphics\blocksets\blockset24_1.cbs","graphics\blocksets\blockset24_2.cbs","graphics\blocksets\blockset25_0.cbs","graphics\blocksets\blockset25_1.cbs","graphics\blocksets\blockset25_2.cbs"

set ROOM_PAL_PREFIX="graphics\roompalettes\pal"
set SPRITE_HI_PAL_PREFIX="graphics\spritepalettes\hi"
set SPRITE_LO_PAL_PREFIX="graphics\spritepalettes\lo"
set MAP_PREFIX="maps\map"

call :EXTRACT_MAP2D "graphics\static\hud\hudtilemap.map" "--width 40" map
call :EXTRACT_MAP2D "graphics\static\inventory\invtilemap.lz77" "--left 80 --top 3" lz77
call :EXTRACT_MAP2D "graphics\static\textbox\threelinetextbox.map" "--width 40" map
call :EXTRACT_MAP2D "graphics\static\textbox\twolinetextbox.map" "--width 40" map

call :EXTRACT_COMPRESSED_STRINGS "strings\main\strings*" "-r main" strings.txt huffmantables.bin huffmancharoffsets.bin
call :EXTRACT_STRINGS "strings\names\characternames.bin" "-r names" characternames.txt
call :EXTRACT_STRINGS "strings\names\defaultname.bin" "-r names" defaultname.txt
call :EXTRACT_STRINGS "strings\names\itemnames.bin" "-r names" itemnames.txt
call :EXTRACT_STRINGS "strings\names\specialcharacternames.bin" "-r names" specialcharacternames.txt
call :EXTRACT_STRINGS "strings\names\system.bin" "-r names" system.txt
call :EXTRACT_STRINGS "strings\intro\string*.bin" "-r intro" intro.tsv
call :EXTRACT_STRINGS "strings\ending\credits.bin" "-r ending" credits.tsv

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

echo Extraction succeeded!

exit /B 0

:FAILURE

echo Test failed, quitting.
exit /B 1