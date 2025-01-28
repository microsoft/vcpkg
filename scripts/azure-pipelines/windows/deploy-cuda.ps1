# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

[string]$CudaUrl
if ([string]::IsNullOrEmpty($SasToken)) {
  Write-Host 'Downloading from the Internet'
  $CudaUrl = 'https://developer.download.nvidia.com/compute/cuda/12.5.0/local_installers/cuda_12.5.0_555.85_windows.exe'
} else {
  Write-Host 'Downloading from vcpkgimageminting using SAS token'
  $SasToken = $SasToken.Replace('"', '')
  $CudaUrl = "https://vcpkgimageminting.blob.core.windows.net/assets/cuda_12.5.0_555.85_windows.exe?$SasToken"
}

# https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/index.html
# Intentionally omitted:
#  demo_suite_12.5
#  documentation_12.5
#  nvvm_samples_12.5
#  visual_studio_integration_12.5
#  Display.Driver
DownloadAndInstall -Name 'CUDA' -Url $CudaUrl -Args @(
  '-s',
  'cublas_12.5',
  'cublas_dev_12.5',
  'cuda_profiler_api_12.5',
  'cudart_12.5',
  'cufft_12.5',
  'cufft_dev_12.5',
  'cuobjdump_12.5',
  'cupti_12.5',
  'curand_12.5',
  'curand_dev_12.5',
  'cusolver_12.5',
  'cusolver_dev_12.5',
  'cusparse_12.5',
  'cusparse_dev_12.5',
  'cuxxfilt_12.5',
  'npp_12.5',
  'npp_dev_12.5',
  'nsight_compute_12.5',
  'nsight_systems_12.5',
  'nsight_vse_12.5',
  'nvcc_12.5',
  'nvdisasm_12.5',
  'nvfatbin_12.5',
  'nvjitlink_12.5',
  'nvjpeg_12.5',
  'nvjpeg_dev_12.5',
  'nvml_dev_12.5',
  'nvprof_12.5',
  'nvprune_12.5',
  'nvrtc_12.5',
  'nvrtc_dev_12.5',
  'nvtx_12.5',
  'occupancy_calculator_12.5',
  'opencl_12.5',
  'sanitizer_12.5',
  'thrust_12.5',
  'visual_profiler_12.5',
  '-n'
)
