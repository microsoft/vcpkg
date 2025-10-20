# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#

param([string]$SasToken)

<#
.SYNOPSIS
Prepares the virtual machine for imaging.

.DESCRIPTION
Runs the `sysprep` utility to prepare the system for imaging.
See https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--system-preparation--overview
for more information.
#>

$ErrorActionPreference = 'Stop'
Write-Host 'Running sysprep'
& C:\Windows\system32\sysprep\sysprep.exe /oobe /generalize /mode:vm /shutdown
