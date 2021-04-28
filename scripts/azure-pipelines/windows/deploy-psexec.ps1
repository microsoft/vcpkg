# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$PsExecPath = 'C:\PsExec64.exe'
Write-Host "Downloading psexec to: $PsExecPath"
& curl.exe -L -o $PsExecPath -s -S https://live.sysinternals.com/PsExec64.exe
