@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass "& {& '%~dp0EnableRemoteDesktop.ps1'}"
