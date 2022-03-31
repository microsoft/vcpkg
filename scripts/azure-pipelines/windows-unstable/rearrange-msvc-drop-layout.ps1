# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#
<#
.SYNOPSIS
Moves files from an MSVC compiler drop to the locations where they are installed in a Visual Studio installation.

.PARAMETER DropRoot
The location where the MSVC compiler drop has been downloaded.

.PARAMETER BuildType
The MSVC drop build type set with /p:_BuildType when MSVC was built. Defaults to 'ret'.

#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$DropRoot,
    [Parameter(Mandatory = $false)][ValidateSet('ret', 'chk')][string]$BuildType = 'ret'
)

Set-StrictMode -Version Latest

$MSVCRoot = "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC"

$ErrorActionPreference = "Stop"

$tempRoot = "$DropRoot\readytodeploy"

New-Item -ItemType Directory -Path $tempRoot | Out-Null

Write-Host "Rearranging x86$BuildType"
New-Item -ItemType Directory -Path "$tempRoot\bin\HostX86" | Out-Null
Move-Item "$DropRoot\binaries.x86$BuildType\bin\i386" "$tempRoot\bin\HostX86\x86"
Move-Item "$DropRoot\binaries.x86$BuildType\bin\x86_amd64" "$tempRoot\bin\HostX86\x64"
Move-Item "$DropRoot\binaries.x86$BuildType\bin\x86_arm" "$tempRoot\bin\HostX86\arm"

Write-Host "Rearranging amd64$BuildType"
New-Item -ItemType Directory -Path "$tempRoot\bin\HostX64" | Out-Null
Move-Item "$DropRoot\binaries.amd64$BuildType\bin\amd64" "$tempRoot\bin\HostX64\x64"
Move-Item "$DropRoot\binaries.amd64$BuildType\bin\amd64_x86" "$tempRoot\bin\HostX64\x86"
Move-Item "$DropRoot\binaries.amd64$BuildType\bin\amd64_arm" "$tempRoot\bin\HostX64\arm"

# Only copy files and directories that already exist in the VS installation.
Write-Host "Rearranging inc, lib"
New-Item -ItemType Directory -Path "$tempRoot\lib" | Out-Null
Move-Item "$DropRoot\binaries.x86$BuildType\inc" "$tempRoot\include"
Move-Item "$DropRoot\binaries.x86$BuildType\lib\i386" "$tempRoot\lib\x86"
Move-Item "$DropRoot\binaries.amd64$BuildType\lib\amd64" "$tempRoot\lib\x64"

Write-Host "Rearranging atlmfc"
New-Item -ItemType Directory -Path "$tempRoot\atlmfc" | Out-Null
New-Item -ItemType Directory -Path "$tempRoot\atlmfc\lib" | Out-Null
Move-Item "$DropRoot\binaries.x86$BuildType\atlmfc\include" "$tempRoot\atlmfc\include"
Move-Item "$DropRoot\binaries.x86$BuildType\atlmfc\lib\i386" "$tempRoot\atlmfc\lib\x86"
Move-Item "$DropRoot\binaries.amd64$BuildType\atlmfc\lib\amd64" "$tempRoot\atlmfc\lib\x64"

[string[]]$toolsets = Get-ChildItem -Path $MSVCRoot -Directory | Sort-Object -Descending
if ($toolsets.Length -eq 0) {
    throw "Could not find Visual Studio toolset!"
}

Write-Host "Found toolsets:`n$($toolsets -join `"`n`")`n"
$selectedToolset = $toolsets[0]
Write-Host "Using toolset: $selectedToolset"
for ($idx = 1; $idx -lt $toolsets.Length; $idx++) {
    $badToolset = $toolsets[$idx]
    Write-Host "Deleting toolset: $badToolset"
    Remove-Item $badToolset -Recurse -Force
}

Write-Host "Deploying $tempRoot => $selectedToolset"
Copy-Item "$tempRoot\*" $selectedToolset -Recurse -Force
Write-Host "Deleting $DropRoot..."
Remove-Item $DropRoot -Recurse -Force
Write-Host "Done!"
