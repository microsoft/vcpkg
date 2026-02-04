# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

[string]$MpiUrl
if ([string]::IsNullOrEmpty($SasToken)) {
  Write-Host 'Downloading from the Internet'
  $MpiUrl = 'https://download.microsoft.com/download/7/2/7/72731ebb-b63c-4170-ade7-836966263a8f/msmpisetup.exe'
} else {
  Write-Host 'Downloading from vcpkgimageminting using SAS token'
  $SasToken = $SasToken.Replace('"', '')
  $MpiUrl = "https://vcpkgimageminting.blob.core.windows.net/assets/msmpisetup-10.1.12498.52.exe?$SasToken"
}

DownloadAndInstall -Name 'MSMPI' -LocalName 'msmpisetup.exe' -Url $MpiUrl -Args @('-force', '-unattend')
