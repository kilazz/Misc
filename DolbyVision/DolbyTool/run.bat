@echo off

REM For ALL SDR panel (support SDR mode only)

powershell.exe Set-ExecutionPolicy -ExecutionPolicy Unrestricted
SET cur_dir=%~dp0
cd /d %cur_dir%

dovi_generate_icc.exe -parse_icc out.bin > out.txt
IF NOT EXIST out.txt (
	ECHO Parse ICC failed, please contact Dolby
	pause
)

powershell.exe .\fix.ps1

IF EXIST out.bin (
	DEL out.bin
)
IF EXIST out.txt (
	DEL out.txt
)

