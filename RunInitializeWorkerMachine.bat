@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass "& {& '%~dp0InitializeWorkerMachine.ps1'}"
