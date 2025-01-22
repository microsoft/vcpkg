# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

[string]$PwshUrl
if ([string]::IsNullOrEmpty($SasToken)) {
  Write-Host 'Downloading from the Internet'
  $PwshUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.4.6/PowerShell-7.4.6-win-x64.msi'
} else {
  Write-Host 'Downloading from vcpkgimageminting using SAS token'
  $SasToken = $SasToken.Replace('"', '')
  $PwshUrl = "https://vcpkgimageminting.blob.core.windows.net/assets/PowerShell-7.4.6-win-x64.msi?$SasToken"
}

DownloadAndInstall -Url $PwshUrl -Name 'PowerShell Core' -Args @('/quiet', '/norestart')
