# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

[string]$CudaUrl
if ([string]::IsNullOrEmpty($SasToken)) {
  Write-Host 'Downloading from the Internet'
  $CudaUrl = 'https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda_12.8.0_571.96_windows.exe'
} else {
  Write-Host 'Downloading from vcpkgimageminting using SAS token'
  $SasToken = $SasToken.Replace('"', '')
  $CudaUrl = "https://vcpkgimageminting.blob.core.windows.net/assets/cuda_12.8.0_571.96_windows.exe?$SasToken"
}

# https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/index.html
# Intentionally omitted:
#  demo_suite_12.8
#  documentation_12.8
#  nsight_compute_12.8
#  nsight_systems_12.8
#  nsight_vse_12.8
#  nvvm_samples_12.8
#  visual_studio_integration_12.8
#  visual_profiler_12.8
#  Display.Driver
DownloadAndInstall -Name 'CUDA' -Url $CudaUrl -Args @(
  '-s',
  'cublas_12.8',
  'cublas_dev_12.8',
  'cuda_profiler_api_12.8',
  'cudart_12.8',
  'cufft_12.8',
  'cufft_dev_12.8',
  'cuobjdump_12.8',
  'cupti_12.8',
  'curand_12.8',
  'curand_dev_12.8',
  'cusolver_12.8',
  'cusolver_dev_12.8',
  'cusparse_12.8',
  'cusparse_dev_12.8',
  'cuxxfilt_12.8',
  'npp_12.8',
  'npp_dev_12.8',
  'nvcc_12.8',
  'nvdisasm_12.8',
  'nvfatbin_12.8',
  'nvjitlink_12.8',
  'nvjpeg_12.8',
  'nvjpeg_dev_12.8',
  'nvml_dev_12.8',
  'nvprof_12.8',
  'nvprune_12.8',
  'nvrtc_12.8',
  'nvrtc_dev_12.8',
  'nvtx_12.8',
  'occupancy_calculator_12.8',
  'opencl_12.8',
  'sanitizer_12.8',
  'thrust_12.8',
  '-n'
)
