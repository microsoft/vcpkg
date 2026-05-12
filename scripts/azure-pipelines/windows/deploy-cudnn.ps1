# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

$CudnnUrl = Get-AssetUrl `
  -SasToken $SasToken `
  -InternetUrl 'https://developer.download.nvidia.com/compute/cudnn/redist/cudnn/windows-x86_64/cudnn-windows-x86_64-9.20.0.48_cuda13-archive.zip' `
  -BlobAssetName 'cudnn-windows-x86_64-9.20.0.48_cuda13-archive.zip'

DownloadAndUnzip -Name 'CUDNN' -Url $CudnnUrl -Destination "$env:ProgramFiles\NVIDIA GPU Computing Toolkit\CUDA\v13.2"

if (Test-Path "$env:ProgramFiles\NVIDIA GPU Computing Toolkit\CUDA\v13.2\include\cudnn.h") {
    Write-Host 'cudnn appears correctly installed'
} else {
    Write-Error 'cudnn appears broken!'
}
