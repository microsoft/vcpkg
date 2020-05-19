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
        [System.IO.Directory]::Delete($Path)
    }
}

# Source: https://github.com/appveyor/ci/blob/master/scripts/path-utils.psm1
function Get-Path
{
    ([Environment]::GetEnvironmentVariable("path", "machine")).Split(";") | Sort-Object
}

function Add-Path([string]$item,[switch]$before)
{
    $item = (Get-SanitizedPath $item)
    $pathItemsArray = ([Environment]::GetEnvironmentVariable("path", "User")).Split(";")
    $pathItems = New-Object System.Collections.ArrayList($null)
    $pathItems.AddRange($pathItemsArray)

    # add folder
    $index = -1
    for($i = 0; $i -lt $pathItems.Count; $i++) {
        if((Get-SanitizedPath $pathItems[$i]) -eq $item) {
            $index = $i;
            break
        }
    }

    if($index -eq -1) {
        # item not found - add it
        if ($before) {
            $pathItems.Insert(0, $item)
        } else {
            $pathItems.Add($item) | Out-null
        }

        # update PATH variable
        $updatedPath = $pathItems -join ';'
        [Environment]::SetEnvironmentVariable("path", $updatedPath, "machine")
    }
}

function Remove-Path([string]$item)
{
    $item = (Get-SanitizedPath $item)
    $pathItemsArray = ([Environment]::GetEnvironmentVariable("path", "machine")).Split(";")
    $pathItems = New-Object System.Collections.ArrayList($null)
    $pathItems.AddRange($pathItemsArray)

    $index = -1
    for($i = 0; $i -lt $pathItems.Count; $i++) {
        if((Get-SanitizedPath $pathItems[$i]) -eq $item) {
            $index = $i;
            break
        }
    }

    if($index -ne -1) {
        # remove folder
        $pathItems.RemoveAt($index) | Out-null

        # update PATH variable
        $updatedPath = $pathItems -join ';'
        [Environment]::SetEnvironmentVariable("path", $updatedPath, "machine")
    }
}

function Get-SanitizedPath([string]$path) {
    return $path.Replace('/', '\').Trim('\')
}

function Add-SessionPath([string]$path) {
    $sanitizedPath = Get-SanitizedPath $path
    foreach($item in $env:path.Split(";")) {
        if($sanitizedPath -eq (Get-SanitizedPath $item)) {
            return # already added
        }
    }
    $env:path = "$sanitizedPath;$env:path"
}

Get-Path Format-List | Out-Host
"`n"

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
if( Test-Path D:\downloads\tools\msys2 )
{
    Write-Host "removing previously installed msys2"
    Remove-Item D:\downloads\tools\msys2 -Recurse -Force
}

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
Remove-DirectorySymlink archives
cmd /c "mklink /D archives $archivesPath"

Write-Host 'Linking installed => E:\installed'
Remove-DirectorySymlink installed
Remove-Item E:\installed -Recurse -Force -ErrorAction SilentlyContinue
mkdir E:\installed
cmd /c "mklink /D installed E:\installed"

Write-Host 'Linking downloads => D:\downloads'
Remove-DirectorySymlink downloads
cmd /c "mklink /D downloads D:\downloads"

Write-Host 'Cleaning buildtrees'
Remove-Item buildtrees\* -Recurse -Force -errorAction silentlycontinue

Write-Host 'Cleaning packages'
Remove-Item packages\* -Recurse -Force -errorAction silentlycontinue
