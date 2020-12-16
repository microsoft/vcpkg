#!pwsh
#Requires -Version 6.0

<#
.SYNOPSIS
Installs the set of prerequisites for the macOS CI hosts.

.DESCRIPTION
Install-Prerequisites.ps1 installs all of the necessary prerequisites
to run the vcpkg macOS CI in a vagrant virtual machine,
skipping all prerequisites that are already installed.

.PARAMETER Force
Don't skip the prerequisites that are already installed.

.INPUTS
None

.OUTPUTS
None
#>
[CmdletBinding()]
Param(
    [Parameter()]
    [Switch]$Force
)

Set-StrictMode -Version 2

if (-not $IsMacOS) {
    Write-Error 'This script should only be run on a macOS host'
    throw
}

Import-Module "$PSScriptRoot/Utilities.psm1"

$Installables = Get-Content "$PSScriptRoot/configuration/installables.json" | ConvertFrom-Json

$Installables.Applications | ForEach-Object {
    if (-not (Get-CommandExists $_.TestCommand)) {
        Write-Host "$($_.Name) not installed; installing now"
    } elseif ($Force) {
        Write-Host "$($_.Name) found; attempting to upgrade or re-install"
    } else {
        Write-Host "$($_.Name) already installed"
        return
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
        brew install $installable.Name
    } else {
        switch ($installable.Kind) {
            'cask' { brew cask install $installable.Name }
            default {
                Write-Error "Invalid kind: $_. Expected either empty, or 'cask'."
            }
         }
     }
}

# Install plugins
$installedExtensionPacks = Get-InstalledVirtualBoxExtensionPacks

$Installables.VBoxExtensions | ForEach-Object {
    $extension = $_
    $installedExts = $installedExtensionPacks | Where-Object { $_.Pack -eq $extension.FullName -and $_.Usable -eq 'true' }

    if ($null -eq $installedExts) {
        Write-Host "VBox extension: $($extension.Name) not installed; installing now"
    } elseif ($Force) {
        Write-Host "VBox extension: $($extension.Name) found; attempting to upgrade or re-install"
    } else {
        Write-Host "VBox extension: $($extension.Name) already installed"
        return
    }

    $pathToExt = "~/Downloads/$($extension.FullName -replace ' ','_').vbox-extpack"

    Get-RemoteFile -OutFile $pathToExt -Uri $extension.Url -Sha256 $extension.Sha256 | Out-Null

    Write-Host 'Attempting to install extension with sudo; you may need to enter your password'
    sudo VBoxManage extpack install --replace $pathToExt
    sudo VBoxManage extpack cleanup
}
