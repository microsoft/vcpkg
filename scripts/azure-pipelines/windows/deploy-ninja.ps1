# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path -LiteralPath "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

$LocalName = 'ninja-win-1.13.2.zip'
$NinjaUrl = Get-AssetUrl `
  -SasToken $SasToken `
  -InternetUrl 'https://github.com/ninja-build/ninja/releases/download/v1.13.2/ninja-win.zip' `
  -BlobAssetName $LocalName

$CMakeBinPath = Join-Path $env:ProgramFiles 'CMake\bin'
if (-not (Test-Path -LiteralPath $CMakeBinPath)) {
  Write-Error "CMake bin directory not found at $CMakeBinPath."
  throw
}

DownloadAndUnzip -Url $NinjaUrl -LocalName $LocalName -Destination $CMakeBinPath

$ninjaExePath = Join-Path $CMakeBinPath 'ninja.exe'
if (Test-Path -LiteralPath $ninjaExePath) {
  Write-Host 'Ninja appears correctly installed.'
} else {
  Write-Error "Ninja appears broken! Missing $ninjaExePath."
}
