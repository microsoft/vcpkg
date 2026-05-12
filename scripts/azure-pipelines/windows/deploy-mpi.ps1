# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

$MpiUrl = Get-AssetUrl `
  -SasToken $SasToken `
  -InternetUrl 'https://download.microsoft.com/download/7/2/7/72731ebb-b63c-4170-ade7-836966263a8f/msmpisetup.exe' `
  -BlobAssetName 'msmpisetup-10.1.12498.52.exe'

DownloadAndInstall -LocalName 'msmpisetup.exe' -Url $MpiUrl -Args @('-force', '-unattend')
