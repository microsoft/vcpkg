# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path -LiteralPath "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

$AzCliUrl = Get-AssetUrl `
  -SasToken $SasToken `
  -InternetUrl 'https://azcliprod.blob.core.windows.net/msi/azure-cli-2.87.0-x64.msi' `
  -BlobAssetName 'azure-cli-2.87.0-x64.msi'

DownloadAndInstall -Url $AzCliUrl -Args @('/quiet', '/norestart')
