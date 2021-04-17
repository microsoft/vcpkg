#!pwsh
#Requires -Version 6.0

<#
.SYNOPSIS
Installs the set of prerequisites for the macOS CI hosts.

.DESCRIPTION
Install-Prerequisites.ps1 installs all of the necessary prerequisites
to run the vcpkg macOS CI in a vagrant virtual machine,
skipping all prerequisites that are already installed and of the right version.

.INPUTS
None

.OUTPUTS
None
#>
[CmdletBinding()]
Param()

Set-StrictMode -Version 2

if (-not $IsMacOS) {
    Write-Error 'This script should only be run on a macOS host'
    throw
}

Import-Module "$PSScriptRoot/Utilities.psm1"

$Installables = Get-Content "$PSScriptRoot/configuration/installables.json" | ConvertFrom-Json

$Installables.Applications | ForEach-Object {
    $VersionCommand = $_.VersionCommand
    if (-not (Get-CommandExists $VersionCommand[0])) {
        Write-Host "$($_.Name) not installed; installing now"
    } else {
        $InstalledVersion = (& $VersionCommand[0] $VersionCommand[1..$VersionCommand.Length]).Trim()
        if ($InstalledVersion -match $_.VersionRegex) {
            if ($Matches.Count -ne 2) {
                Write-Error "$($_.Name) has a malformed version regex ($($_.VersionRegex)); it should have a single capture group
    (it has $($Matches.Count - 1))"
                throw
            }
            if ($Matches[1] -eq $_.Version) {
                Write-Host "$($_.Name) already installed and at the correct version ($($Matches[1]))"
                return
            } else {
                Write-Host "$($_.Name) already installed but with the incorrect version
    installed version: '$($Matches[1])'
    required version : '$($_.Version)'
upgrading now."
            }
        } else {
            Write-Warning "$($_.Name)'s version command ($($VersionCommand -join ' ')) returned a value we did not expect:
    $InstalledVersion
    expected a version matching the regex: $($_.VersionRegex)
Installing anyways."
        }
    }

    $pathToDmg = "~/Downloads/$($_.Name).dmg"
    Get-RemoteFile -OutFile $pathToDmg -Uri $_.DmgUrl -Sha256 $_.Sha256

    hdiutil attach $pathToDmg -mountpoint /Volumes/setup-installer
    sudo installer -pkg "/Volumes/setup-installer/$($_.InstallerPath)" -target /
    hdiutil detach /Volumes/setup-installer
}

$Installables.Brew | ForEach-Object {
    $installable = $_
    if ($null -eq (Get-Member -InputObject $installable -Name 'Kind')) {
        brew reinstall $installable.Name
    } else {
        switch ($installable.Kind) {
            'cask' { brew reinstall --cask $installable.Name }
            default {
                Write-Error "Invalid kind: $_. Expected either empty, or 'cask'."
            }
         }
     }
}
