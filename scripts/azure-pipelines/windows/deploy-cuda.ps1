# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

[string]$CudaUrl
if ([string]::IsNullOrEmpty($SasToken)) {
  Write-Host 'Downloading from the Internet'
  $CudaUrl = 'https://developer.download.nvidia.com/compute/cuda/12.9.1/local_installers/cuda_12.9.1_576.57_windows.exe'
} else {
  Write-Host 'Downloading from vcpkgimageminting using SAS token'
  $SasToken = $SasToken.Replace('"', '')
  $CudaUrl = "https://vcpkgimageminting.blob.core.windows.net/assets/cuda_12.9.1_576.57_windows.exe?$SasToken"
}

# https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/index.html
# Intentionally omitted:
#  demo_suite_12.9
#  documentation_12.9
#  nsight_compute_12.9
#  nsight_systems_12.9
#  nsight_vse_12.9
#  nvvm_samples_12.9
#  visual_studio_integration_12.9
#  visual_profiler_12.9
#  Display.Driver
DownloadAndInstall -Name 'CUDA' -Url $CudaUrl -Args @(
  '-s',
  'cublas_12.9',
  'cublas_dev_12.9',
  'cuda_profiler_api_12.9',
  'cudart_12.9',
  'cufft_12.9',
  'cufft_dev_12.9',
  'cuobjdump_12.9',
  'cupti_12.9',
  'curand_12.9',
  'curand_dev_12.9',
  'cusolver_12.9',
  'cusolver_dev_12.9',
  'cusparse_12.9',
  'cusparse_dev_12.9',
  'cuxxfilt_12.9',
  'npp_12.9',
  'npp_dev_12.9',
  'nvcc_12.9',
  'nvdisasm_12.9',
  'nvfatbin_12.9',
  'nvjitlink_12.9',
  'nvjpeg_12.9',
  'nvjpeg_dev_12.9',
  'nvml_dev_12.9',
  'nvprof_12.9',
  'nvprune_12.9',
  'nvrtc_12.9',
  'nvrtc_dev_12.9',
  'nvtx_12.9',
  'occupancy_calculator_12.9',
  'opencl_12.9',
  'sanitizer_12.9',
  'thrust_12.9',
  '-n'
)
