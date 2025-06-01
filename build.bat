@echo off
setlocal enabledelayedexpansion
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
cd /d "%~dp0"

set infile=src/main.c
set outfile=main

del %outfile%.exe %outfile%.obj %outfile%.ilk %outfile%.pdb %outfile%.rdi
for %%A in (%*) do (
    set "%%A=1"
)

set common_flags=/Zc:preprocessor /RTC1 /GA /Gw /permissive /fastfail /sdl /I.\src\base
set no_annoying_warnings=/wd4477 /wd4996
set no_annoying_cpp_warnings=
set opt_flags=/O2 /Ot /Ob3 /GL /Qpar /Qspectre-load /Qspectre-load-cf
set dbg_flags=/Od /Zi /fsanitize=address /DDEBUG=1 /DENABLE_ASSERT=1
set links=/link Ws2_32.lib

set cpp_mode=/TP /std:c++latest
set sound_mode=/DOS_SOUND=1
set gui_mode=/DOS_GUI=1 %sound_mode%

set flags=%common_flags% %no_annoying_warnings%
if defined cpp set flags=%flags% %cpp_mode% %no_annoying_cpp_warnings%
if defined sound set flags=%flags% %sound_mode%
if defined gui (
   set flags=%flags% %gui_mode%
   set links=%links% User32.lib
)
if not defined release (
  set flags=%flags% %dbg_flags%
) else (
  set flags=%flags% %opt_flags%
)

cl %flags% /Fe%outfile%.exe %infile% %links%

endlocal
