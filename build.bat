@ECHO OFF

REM // Rename previously successful build if one existed.
IF EXIST s1built.bin move /Y s1built.bin s1built.prev.bin > NUL

REM // Run the ASM68K assembly with the following parameters:
REM //   k  >>  allow use of ifeq, etc.
REM //   m  >>  expand macros in listing file
REM //   o ___  >>  set assembler options/optimisations:
REM //     ws+  >>  allow white space in operands
REM //     op+  >>  allow pc relative optimisation
REM //     os+  >>  allow short branch optimisation
REM //     ow+  >>  allow absolute word addressing optimisation
REM //     oz+  >>  enable zero offset optimisation
REM //     oaq+  >>  enable addq optimisation
REM //     osq+  >>  enable subq optimisation
REM //     omq+  >>  enable moveq optimisation
REM //     ae-  >>  disable automatic even on dc/dcb/ds/rs .w/l
REM //     v+  >>  allow write local labels to symbol file
REM //     c+   >>  enable case sensitivity
REM //     l+   >>  use '.' as leading character for local labels
REM // 
REM // Files:
REM //   sonic.asm    >>  input assembly file
REM //   s1built.bin  >>  assembled ROM
REM //   [blank]      >>  symbol file (disabled)
REM //   sonic.lst    >>  listing file
REM //   sonic.log    >>  console output redirected to log file
"build_tools\asm68k.exe" /k /m /o ws+,op+,os+,ow+,oz+,oaq+,osq+,omq+,ae-,v+,c+,l+ /p sonic.asm, s1built.bin, s1built.sym, sonic.lst > sonic.log

REM // Still print redirected log output to console (Batch doesn't suppport tee).
type sonic.log

REM // Generate debug information
if exist s1built.sym (
    "build_tools\convsym.exe" s1built.sym s1built.bin -a -range 0 FFFFFF -inopt "/localSign=." -exclude -filter "(SMPS_(Track|RAM).*)|(.+_(END|End|end))"
    if exist s1built.sym del s1built.sym
)

REM // Fix checksum (only if output was generated).
if exist s1built.bin (
    "build_tools\fixheadr.exe" s1built.bin
)

REM // If assembly produced warnings or errors, pause here so that the user can read them.
findstr /i /c:"Warning :" /c:"Error :" sonic.log > NUL
if not errorlevel 1 (
    echo.
    pause
)
