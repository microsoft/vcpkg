@echo off
setlocal enabledelayedexpansion
set mypath=%~dp0
set mypath=%mypath:~0,-1%
set BAKCD=!CD!
cd /D %mypath%\..\..\..\debug\bin
set PATH=!CD!;%PATH%
"%mypath%\windeployqt.exe" --qtpaths "%mypath%\qtpaths.debug.bat" %*
cd %BAKCD%
endlocal
