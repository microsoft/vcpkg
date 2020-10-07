# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#
<#
.SYNOPSIS
Sets up the environment to run other vcpkg CI steps in an Azure Pipelines job.

.DESCRIPTION
This script maps network drives from infrastructure and cleans out anything that
might have been leftover from a previous run.
#>

if ([string]::IsNullOrWhiteSpace($env:StorageAccountName) -or  [string]::IsNullOrWhiteSpace($env:StorageAccountKey)) {
    Write-Host 'No storage account and/or key set, skipping mount of W:\'
} else {
    $StorageAccountName = $env:StorageAccountName
    $StorageAccountKey = $env:StorageAccountKey

    Write-Host 'Setting up archives mount'
    if (-Not (Test-Path W:)) {
        net use W: "\\$StorageAccountName.file.core.windows.net\archives" /u:"AZURE\$StorageAccountName" $StorageAccountKey
    }
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
