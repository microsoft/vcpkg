# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

[string]$AzCliUrl
if ([string]::IsNullOrEmpty($SasToken)) {
  $AzCliUrl = 'https://azcliprod.blob.core.windows.net/msi/azure-cli-2.62.0-x64.msi'
} else {
  $SasToken = $SasToken.Replace('"', '')
  $AzCliUrl = "https://vcpkgimageminting.blob.core.windows.net/assets/azure-cli-2.62.0-x64.msi?$SasToken"
}

DownloadAndInstall -Url $AzCliUrl -Name 'Azure CLI' -Args @('/quiet', '/norestart')
