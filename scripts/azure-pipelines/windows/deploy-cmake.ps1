# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

if (Test-Path -LiteralPath "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

$CMakeUrl = Get-AssetUrl `
  -InternetUrl 'https://github.com/Kitware/CMake/releases/download/v4.4.0/cmake-4.4.0-windows-x86_64.msi' `
  -BlobAssetName 'cmake-4.4.0-windows-x86_64.msi'

DownloadAndInstall -Url $CMakeUrl -Args @('/quiet', '/norestart', 'ADD_CMAKE_TO_PATH=System')

$cmakeExePath = Join-Path $env:ProgramFiles 'CMake\bin\cmake.exe'
if (Test-Path -LiteralPath $cmakeExePath) {
  Write-Host 'CMake appears correctly installed.'
} else {
  Write-Error "CMake appears broken! Missing $cmakeExePath."
}
