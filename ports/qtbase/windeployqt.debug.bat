@echo off
setlocal
set mypath=%~dp0
set mypath=%mypath:~0,-1%
cd %mypath%\..\..\..\debug\bin
set BAKCD=%CD%
set PATH=%CD%;%PATH%
"%mypath%\windeployqt.exe" --qtpaths "%mypath%\qtpaths.debug.bat" %*
cd %BAKCD%
endlocal