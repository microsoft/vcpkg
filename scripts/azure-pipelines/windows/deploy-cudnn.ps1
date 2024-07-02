# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

[string]$CudnnUrl
if ([string]::IsNullOrEmpty($SasToken)) {
  $CudnnUrl = 'https://developer.download.nvidia.com/compute/cudnn/redist/cudnn/windows-x86_64/cudnn-windows-x86_64-9.2.0.82_cuda12-archive.zip'
} else {
  $SasToken = $SasToken.Replace('"', '')
  $CudnnUrl = "https://vcpkgimageminting.blob.core.windows.net/assets/cudnn-windows-x86_64-9.2.0.82_cuda12-archive.zip?$SasToken"
}

DownloadAndUnzip -Name 'CUDNN' -Url $CudnnUrl -Destination "$env:ProgramFiles\NVIDIA GPU Computing Toolkit\CUDA\v12.5"

if (Test-Path "$env:ProgramFiles\NVIDIA GPU Computing Toolkit\CUDA\v12.5\include\cudnn.h") {
    Write-Host 'cudnn appears correctly installed'
} else {
    Write-Error 'cudnn appears broken!'
}
