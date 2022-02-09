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
    $InstalledVersion = (& $VersionCommand[0] $VersionCommand[1..$VersionCommand.Length])
    if (-not $?) {
        Write-Host "$($_.Name) not installed; installing now"
    } else {
        $InstalledVersion = $InstalledVersion -join "`n"
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

    if ($null -ne (Get-Member -InputObject $_ -Name 'DmgUrl')) {
        $pathToDmg = "~/Downloads/$($_.Name).dmg"
        Get-RemoteFile -OutFile $pathToDmg -Uri $_.DmgUrl -Sha256 $_.Sha256

        hdiutil attach $pathToDmg -mountpoint /Volumes/setup-installer

        if ($null -ne (Get-Member -InputObject $_ -Name 'InstallationCommands')) {
            $_.InstallationCommands | % {
                Write-Host "> $($_ -join ' ')"
                & $_[0] $_[1..$_.Length] | Write-Host
            }
        } elseif ($null -ne (Get-Member -InputObject $_ -Name 'InstallerPath')) {
            sudo installer -pkg "/Volumes/setup-installer/$($_.InstallerPath)" -target /
            hdiutil detach /Volumes/setup-installer
        } else {
            Write-Error "$($_.Name) installer object has a DmgUrl, but neither an InstallerPath nor an InstallationCommands"
            throw
        }
    } elseif ($null -ne (Get-Member -InputObject $_ -Name 'PkgUrl')) {
        $pathToPkg = "~/Downloads/$($_.Name).pkg"
        Get-RemoteFile -OutFile $pathToPkg -Uri $_.PkgUrl -Sha256 $_.Sha256

        sudo installer -pkg $pathToPkg -target /
    } else {
        Write-Error "$($_.Name) does not have an installer in the configuration file."
        throw
    }
}

$installedVagrantPlugins = @{}
vagrant plugin list --machine-readable | ForEach-Object {
    $timestamp, $target, $type, $data = $_ -split ','
    switch ($type) {
        # these are not important
        'ui' { }
        'plugin-version-constraint' { }
        'plugin-name' {
            $installedVagrantPlugins[$data] = $Null
        }
        'plugin-version' {
            $version = $data -replace '%!\(VAGRANT_COMMA\)',','
            if ($version -notmatch '^(.*), global') {
                Write-Error "Invalid version string for plugin ${target}: $version"
                throw
            }
            $installedVagrantPlugins[$target] = $Matches[1]
        }
        default {
            Write-Warning "Unknown plugin list member type $type for plugin $target"
        }
    }
}
$Installables.VagrantPlugins | ForEach-Object {
    if (-not $installedVagrantPlugins.Contains($_.Name)) {
        Write-Host "$($_.Name) not installed; installing now"
    } elseif ($installedVagrantPlugins[$_.Name] -ne $_.Version) {
        Write-Host "$($_.Name) already installed but with the incorrect version
    installed version: '$($installedVagrantPlugins[$_.Name])'
    required version:  '$($_.Version)'"
    } else {
        Write-Host "$($_.Name) already installed and at the correct version ($($_.Version))"
        return
    }

    vagrant plugin install $_.Name --plugin-version $_.Version
}
