@echo off
setlocal
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0crtsys-vs-init.ps1" %*
exit /b %ERRORLEVEL%
