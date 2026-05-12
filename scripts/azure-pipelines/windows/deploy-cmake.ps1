# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path -LiteralPath "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

$CMakeUrl = Get-AssetUrl `
  -SasToken $SasToken `
  -InternetUrl 'https://github.com/Kitware/CMake/releases/download/v4.3.2/cmake-4.3.2-windows-x86_64.msi' `
  -BlobAssetName 'cmake-4.3.2-windows-x86_64.msi'

DownloadAndInstall -Url $CMakeUrl -Args @('/quiet', '/norestart', 'ADD_CMAKE_TO_PATH=System')

$cmakeExePath = Join-Path $env:ProgramFiles 'CMake\bin\cmake.exe'
if (Test-Path -LiteralPath $cmakeExePath) {
  Write-Host 'CMake appears correctly installed.'
} else {
  Write-Error "CMake appears broken! Missing $cmakeExePath."
}
