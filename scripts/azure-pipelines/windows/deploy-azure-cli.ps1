# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

if (Test-Path -LiteralPath "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

$AzCliUrl = Get-AssetUrl `
  -InternetUrl 'https://azcliprod.blob.core.windows.net/msi/azure-cli-2.88.0-x64.msi' `
  -BlobAssetName 'azure-cli-2.88.0-x64.msi'

DownloadAndInstall -Url $AzCliUrl -Args @('/quiet', '/norestart')
