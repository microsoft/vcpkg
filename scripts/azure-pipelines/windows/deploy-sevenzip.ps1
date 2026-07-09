# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path -LiteralPath "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

$SevenZipUrl = Get-AssetUrl `
  -SasToken $SasToken `
  -InternetUrl 'https://github.com/ip7z/7zip/releases/download/26.01/7z2601-x64.exe' `
  -BlobAssetName '7z2601-x64.exe'

DownloadAndInstall -Url $SevenZipUrl -Args @('/S')
