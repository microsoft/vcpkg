@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass "& {& \"%~dp0scripts\bootstrap.ps1\" %*}"
