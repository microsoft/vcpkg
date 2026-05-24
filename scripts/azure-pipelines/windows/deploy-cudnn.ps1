# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path -LiteralPath "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

$CudnnUrl = Get-AssetUrl `
  -SasToken $SasToken `
  -InternetUrl 'https://developer.download.nvidia.com/compute/cudnn/redist/cudnn/windows-x86_64/cudnn-windows-x86_64-9.20.0.48_cuda13-archive.zip' `
  -BlobAssetName 'cudnn-windows-x86_64-9.20.0.48_cuda13-archive.zip'

[System.IO.DirectoryInfo]$CudnnInstallDir = "$env:ProgramFiles\NVIDIA GPU Computing Toolkit\CUDA\v13.2"

DownloadAndUnzip -Url $CudnnUrl -Destination $CudnnInstallDir -StripRootDirectory

$CudnnHeaderPath = Join-Path $CudnnInstallDir "include\cudnn.h"
if (Test-Path -LiteralPath $CudnnHeaderPath) {
    Write-Host 'cudnn appears correctly installed'
} else {
    Write-Error 'cudnn appears broken!'
}
