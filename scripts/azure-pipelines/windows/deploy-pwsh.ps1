# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

if (Test-Path -LiteralPath "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

$PwshUrl = Get-AssetUrl `
  -InternetUrl 'https://github.com/PowerShell/PowerShell/releases/download/v7.6.3/PowerShell-7.6.3-win-x64.msi' `
  -BlobAssetName 'PowerShell-7.6.3-win-x64.msi'

DownloadAndInstall -Url $PwshUrl -Args @('/quiet', '/norestart')
