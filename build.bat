@echo off

IF EXIST s1built.bin move /Y s1built.bin s1built.prev.bin >NUL
asm68k /k /m /p /o ae-,oz+,c+,l+ sonic.asm, s1built.bin >sonic.log, , sonic.lst
type sonic.log
fixheadr.exe s1built.bin
