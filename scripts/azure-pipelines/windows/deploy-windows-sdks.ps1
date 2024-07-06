# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

[string]$WdkUrl
if ([string]::IsNullOrEmpty($SasToken)) {
  $WdkUrl = 'https://go.microsoft.com/fwlink/?linkid=2128854'
} else {
  $SasToken = $SasToken.Replace('"', '')
  $WdkUrl = "https://vcpkgimageminting.blob.core.windows.net/assets/wdksetup.exe?$SasToken"
}

DownloadAndInstall -Name 'Windows 10 WDK, version 2004' -Url $WdkUrl -Args @('/features', '+', '/q') -LocalName 'wdksetup.exe'
