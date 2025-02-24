# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

[string]$CudnnUrl
if ([string]::IsNullOrEmpty($SasToken)) {
  Write-Host 'Downloading from the Internet'
  $CudnnUrl = 'https://developer.download.nvidia.com/compute/cudnn/redist/cudnn/windows-x86_64/cudnn-windows-x86_64-9.7.0.66_cuda12-archive.zip'
} else {
  Write-Host 'Downloading from vcpkgimageminting using SAS token'
  $SasToken = $SasToken.Replace('"', '')
  $CudnnUrl = "https://vcpkgimageminting.blob.core.windows.net/assets/cudnn-windows-x86_64-9.7.0.66_cuda12-archive.zip?$SasToken"
}

DownloadAndUnzip -Name 'CUDNN' -Url $CudnnUrl -Destination "$env:ProgramFiles\NVIDIA GPU Computing Toolkit\CUDA\v12.8"

if (Test-Path "$env:ProgramFiles\NVIDIA GPU Computing Toolkit\CUDA\v12.8\include\cudnn.h") {
    Write-Host 'cudnn appears correctly installed'
} else {
    Write-Error 'cudnn appears broken!'
}
