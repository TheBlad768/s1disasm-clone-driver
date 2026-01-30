@echo OFF
setlocal EnableDelayedExpansion

REM // Build the ROM.
call build

if exist s1built.bin (
	REM // Hash the ROM.
	for /f "tokens=1" %%H in ('
		certutil -hashfile "s1built.bin" MD5 ^| findstr /v "hash"
	') do set HASH=%%H

	REM // Verify the hash against known builds.
	echo -------------------------------------------------------------
	if /I "!HASH!"=="1BC674BE034E43C96B86487AC69D9293" (
		echo ROM is bit-perfect with REV00.
	) else if /I "!HASH!"=="09DADB5071EB35050067A32462E39C5F" (
		echo ROM is bit-perfect with REV01.
	) else if /I "!HASH!"=="C6C15AEA60BDA10AE11C6BC375296153" (
		echo ROM is bit-perfect with REVXB.
	) else (
		echo ROM is NOT bit-perfect with REV00, REV01, or REVXB!
	)
)

REM // Prevent the window from disappearing immediately.
pause

