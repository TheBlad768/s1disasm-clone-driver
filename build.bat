@echo off

IF EXIST s1built.bin move /Y s1built.bin s1built.prev.bin >NUL
asm68k /k /m /p /o ae-,c+,l+ sonic.asm, s1built.bin >errors.txt, , sonic.lst
type errors.txt
fixheadr.exe s1built.bin
