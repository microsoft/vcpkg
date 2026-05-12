# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

[string]$AzCopyUrl
if ([string]::IsNullOrEmpty($SasToken)) {
  $AzCopyUrl = 'https://github.com/Azure/azure-storage-azcopy/releases/download/v10.32.3/azcopy_windows_amd64_10.32.3.zip'
} else {
  $SasToken = $SasToken.Replace('"', '')
  $AzCopyUrl = "https://vcpkgimageminting.blob.core.windows.net/assets/azcopy_windows_amd64_10.32.3.zip?$SasToken"
}

mkdir -Force "C:\AzCopy10"
DownloadAndUnzip -Name 'azcopy' -Url $AzCopyUrl -Destination "C:\AzCopy10"
