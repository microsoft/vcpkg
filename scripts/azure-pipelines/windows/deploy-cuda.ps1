# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

[string]$CudaUrl
if ([string]::IsNullOrEmpty($SasToken)) {
  Write-Host 'Downloading from the Internet'
  $CudaUrl = 'https://developer.download.nvidia.com/compute/cuda/13.2.0/local_installers/cuda_13.2.0_windows.exe'
} else {
  Write-Host 'Downloading from vcpkgimageminting using SAS token'
  $SasToken = $SasToken.Replace('"', '')
  $CudaUrl = "https://vcpkgimageminting.blob.core.windows.net/assets/cuda_13.2.0_windows.exe?$SasToken"
}

# https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/index.html
# Intentionally omitted:
#  documentation_13.2
#  nsight_compute_13.2
#  nsight_systems_13.2
#  nsight_vse_13.2
#  visual_studio_integration_13.2
DownloadAndInstall -Name 'CUDA' -Url $CudaUrl -Args @(
  '-s',
  'cublas_13.2',
  'cublas_dev_13.2',
  'cuda_profiler_api_13.2',
  'cudart_13.2',
  'cufft_13.2',
  'cufft_dev_13.2',
  'cuobjdump_13.2',
  'cupti_13.2',
  'curand_13.2',
  'curand_dev_13.2',
  'cusolver_13.2',
  'cusolver_dev_13.2',
  'cusparse_13.2',
  'cusparse_dev_13.2',
  'cuxxfilt_13.2',
  'npp_13.2',
  'npp_dev_13.2',
  'nvcc_13.2',
  'nvdisasm_13.2',
  'nvfatbin_13.2',
  'nvjitlink_13.2',
  'nvjpeg_13.2',
  'nvjpeg_dev_13.2',
  'nvml_dev_13.2',
  'nvprune_13.2',
  'nvrtc_13.2',
  'nvrtc_dev_13.2',
  'nvtx_13.2',
  'occupancy_calculator_13.2',
  'opencl_13.2',
  'sanitizer_13.2',
  'thrust_13.2',
  '-n'
)
