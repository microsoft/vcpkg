@echo off
setlocal
set mypath=%~dp0
set mypath=%mypath:~0,-1%
cd %mypath%\..\..\..\debug\bin
set BAKCD=%CD%
set PATH=%CD%;%PATH%
"%mypath%\windeployqt.exe" --qmake "%mypath%\qmake.debug.bat" %*
cd %BAKCD%
endlocal