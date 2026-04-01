@echo off

IF EXIST s1built.bin move /Y s1built.bin s1built.prev.bin >NUL
"build_tools\asm68k.exe" /k /m /p /o ae-,oz+,c+,l+ sonic.asm, s1built.bin >sonic.log, , sonic.lst
if exist s1built.bin (
    "build_tools\fixheadr.exe" s1built.bin	
) else (
    type sonic.log
    echo.
    pause REM // Pause on failure so that the user can read the error message.
)	
