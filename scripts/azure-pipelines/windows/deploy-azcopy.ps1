# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

if (Test-Path -LiteralPath "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

$AzCopyUrl = Get-AssetUrl `
  -InternetUrl 'https://github.com/Azure/azure-storage-azcopy/releases/download/v10.32.8/azcopy_windows_amd64_10.32.8.zip' `
  -BlobAssetName 'azcopy_windows_amd64_10.32.8.zip'

mkdir -Force "C:\AzCopy10"
DownloadAndUnzip -Url $AzCopyUrl -Destination "C:\AzCopy10" -StripRootDirectory
