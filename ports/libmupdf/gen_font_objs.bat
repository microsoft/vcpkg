@echo off

setlocal ENABLEDELAYEDEXPANSION
set BIN2OBJ=%1
set TARGET_DIR=%2
set TARGET_MODE=%3

echo "Using bin2obj.exe = %BIN2OBJ%"
echo "Target directory = %TARGET_DIR%"

if exist "%TARGET_DIR%" (
  echo "%TARGET_DIR% already exist."
) else (
  md "%TARGET_DIR%"
)

for /r ./resources/fonts/ %%i in (*.ttf *.ttc *.otf *.cff) do (
  echo %%i
  set FONTFILE=%%i
  set OBJFILE="%%~nxi"
  set FONTFILE_0=%%~nxi
  set FONTFILE_1=!FONTFILE_0:-=_!
  set FONTFILE_2=!FONTFILE_1:.=_!
  "%BIN2OBJ%" "!FONTFILE!" "%TARGET_DIR%/!OBJFILE!.obj" "_binary_!FONTFILE_2!" "%TARGET_MODE%"
  echo "Process font file: !FONTFILE!"
  echo "Target file: %TARGET_DIR%/!OBJFILE!.obj"
)

echo "Process end."


