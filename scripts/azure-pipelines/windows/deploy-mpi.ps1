# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

[string]$MpiUrl
if ([string]::IsNullOrEmpty($SasToken)) {
  $MpiUrl = 'https://download.microsoft.com/download/a/5/2/a5207ca5-1203-491a-8fb8-906fd68ae623/msmpisetup.exe'
} else {
  $SasToken = $SasToken.Replace('"', '')
  $MpiUrl = "https://vcpkgimageminting.blob.core.windows.net/assets/msmpisetup.exe?$SasToken"
}

DownloadAndInstall -Name 'MSMPI' -Url $MpiUrl -Args @('-force', '-unattend')
