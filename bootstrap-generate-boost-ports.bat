@echo off
cd /D "%~dp0"
set PATH=%PATH%;%~dp0
powershell.exe -NoProfile -ExecutionPolicy Bypass "& {& '%~dp0scripts\boost\generate-ports.ps1' %*}"
