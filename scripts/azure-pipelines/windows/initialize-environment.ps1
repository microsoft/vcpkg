# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#
<#
.SYNOPSIS
Sets up the environment to run other vcpkg CI steps in an Azure Pipelines job.

.DESCRIPTION
This script maps network drives from infrastructure and cleans out anything that
might have been leftover from a previous run.

.PARAMETER ForceAllPortsToRebuildKey
A subdirectory / key to use to force a build without any previous run caching,
if necessary.
#>

[CmdletBinding()]
Param(
    [string]$ForceAllPortsToRebuildKey = ''
)

$StorageAccountName = $env:StorageAccountName
$StorageAccountKey = $env:StorageAccountKey

function Remove-DirectorySymlink {
    Param([string]$Path)
    if (Test-Path $Path) {
        [System.IO.Directory]::Delete($Path, $true)
    }
}

Write-Host 'Setting up archives mount'
if (-Not (Test-Path W:)) {
    net use W: "\\$StorageAccountName.file.core.windows.net\archives" /u:"AZURE\$StorageAccountName" $StorageAccountKey
}

Write-Host 'Creating downloads directory'
mkdir D:\downloads -ErrorAction SilentlyContinue

# Delete entries in the downloads folder, except:
#   those in the 'tools' folder
#   those last accessed in the last 30 days
Get-ChildItem -Path D:\downloads -Exclude "tools" `
    | Where-Object{ $_.LastAccessTime -lt (get-Date).AddDays(-30) } `
    | ForEach-Object{Remove-Item -Path $_ -Recurse -Force}

# Msys sometimes leaves a database lock file laying around, especially if there was a failed job
# which causes unrelated failures in jobs that run later on the machine.
# work around this by just removing the vcpkg installed msys2 if it exists



Write-Host 'Setting up archives path...'
if ([string]::IsNullOrWhiteSpace($ForceAllPortsToRebuildKey))
{
    $archivesPath = 'W:\'
}
else
{
    $archivesPath = "W:\force\$ForceAllPortsToRebuildKey"
    if (-Not (Test-Path $fullPath)) {
        Write-Host 'Creating $archivesPath'
        mkdir $archivesPath
    }
}

Write-Host "Linking archives => $archivesPath"
if (-Not (Test-Path archives)) {
    cmd /c "mklink /D archives $archivesPath"
}

Write-Host 'Linking installed => E:\installed'
if (-Not (Test-Path E:\installed)) {
    mkdir E:\installed
}

if (-Not (Test-Path installed)) {
    cmd /c "mklink /D installed E:\installed"
}

Write-Host 'Linking downloads => D:\downloads'
if (-Not (Test-Path D:\downloads)) {
    mkdir D:\downloads
}

if (-Not (Test-Path downloads)) {
    cmd /c "mklink /D downloads D:\downloads"
}

if( Test-Path C:\agent\_work\1\s\downloads\tools\msys2 )
{
    Write-Host "removing previously installed msys2"
    function bash($command) {
        Write-Host $command -NoNewline
        cmd /c start /wait C:\agent\_work\1\s\downloads\tools\msys2\msys64\usr\bin\sh.exe --login -c $command
        Write-Host " - OK" -ForegroundColor Green
    }
}

# update core packages
bash "PATH=/usr/bin;pacman -Syuu --needed --noconfirm --ask=20 --overwrite '*'" 
#bash "PATH=/usr/bin;pacman-key --init;pacman-key --populate msys2;pacman-key --refresh-keys;pacman --sync pacman --refresh --sysupgrade --sysupgrade --overwrite '*'"

#if( Test-Path D:\downloads\tools\msys2 )
#{
#Get-Acl "D:\\downloads\\tools\\msys2" |Format-List | Out-Host
#"`n"
#}
