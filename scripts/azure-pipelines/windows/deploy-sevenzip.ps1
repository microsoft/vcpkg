# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

if (Test-Path -LiteralPath "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

$SevenZipUrl = Get-AssetUrl `
  -InternetUrl 'https://github.com/ip7z/7zip/releases/download/26.02/7z2602-x64.exe' `
  -BlobAssetName '7z2602-x64.exe'

DownloadAndInstall -Url $SevenZipUrl -Args @('/S')
