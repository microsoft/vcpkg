# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

<#
.SYNOPSIS
Partitions a new physical disk.
.DESCRIPTION
Takes the disk $DiskNumber, turns it on, then partitions it for use with label
$Label and drive letter $Letter.
.PARAMETER DiskNumber
The number of the disk to set up.
.PARAMETER Letter
The drive letter at which to mount the disk.
.PARAMETER Label
The label to give the disk.
#>
Function New-PhysicalDisk {
Param(
    [int]$DiskNumber,
    [string]$Letter,
    [string]$Label
)
    if ($Letter.Length -ne 1) {
        throw "Bad drive letter $Letter, expected only one letter. (Did you accidentially add a : ?)"
    }

    try {
        Write-Host "Attempting to online physical disk $DiskNumber"
        [string]$diskpartScriptPath = Get-TempFilePath -Extension 'txt'
        [string]$diskpartScriptContent =
        "SELECT DISK $DiskNumber`r`n" +
        "ONLINE DISK`r`n"

        Write-Host "Writing diskpart script to $diskpartScriptPath with content:"
        Write-Host $diskpartScriptContent
        Set-Content -Path $diskpartScriptPath -Value $diskpartScriptContent
        Write-Host 'Invoking DISKPART...'
        & diskpart.exe /s $diskpartScriptPath

        Write-Host "Provisioning physical disk $DiskNumber as drive $Letter"
        [string]$diskpartScriptContent =
        "SELECT DISK $DiskNumber`r`n" +
        "ATTRIBUTES DISK CLEAR READONLY`r`n" +
        "CREATE PARTITION PRIMARY`r`n" +
        "FORMAT FS=NTFS LABEL=`"$Label`" QUICK`r`n" +
        "ASSIGN LETTER=$Letter`r`n"
        Write-Host "Writing diskpart script to $diskpartScriptPath with content:"
        Write-Host $diskpartScriptContent
        Set-Content -Path $diskpartScriptPath -Value $diskpartScriptContent
        Write-Host 'Invoking DISKPART...'
        & diskpart.exe /s $diskpartScriptPath
    }
    catch {
        Write-Error "Failed to provision physical disk $DiskNumber as drive $Letter! $($_.Exception.Message)"
    }
}

New-PhysicalDisk -DiskNumber 1 -Letter 'E' -Label 'install disk'
