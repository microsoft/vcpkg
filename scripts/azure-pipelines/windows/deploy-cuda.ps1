# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

if (Test-Path -LiteralPath "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

$CudaUrl = Get-AssetUrl `
  -InternetUrl 'https://developer.download.nvidia.com/compute/cuda/13.3.1/local_installers/cuda_13.3.1_windows.exe' `
  -BlobAssetName 'cuda_13.3.1_windows.exe'

# https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/index.html
# On version updates, extract the package manifests from the installer with:
#  7z x cuda_<version>_windows.exe -o<output> -ir!*.nvi
# Each manifest whose customInstallTree/treeNode has accessibility="selectable" names a valid package
# in its root <nvi name="..."> element. Compare those names with both lists below; NVIDIA changes the
# package names and composition between releases. Confirm every omission is still related to drivers,
# documentation, or Visual Studio.
#
# Intentionally omitted due to being Visual Studio / GUI features:
#  ctadvisor_13.3
#  nsight_compute_13.3
#  nsight_systems_13.3
#  nsight_vse_13.3
#  visual_studio_integration_13.3
# Intentionally omitted due to being documentation:
#  documentation_13.3
#  occupancy_calculator_13.3 (this is named like a tool but listed as 'documentation' in the installer)
# (Drivers used to be omitted but as of CUDA 13 they no longer seem to be in the CUDA installer)
DownloadAndInstall -Url $CudaUrl -Args @(
  '-s',
  'crt_13.3',
  'cublas_13.3',
  'cublas_dev_13.3',
  'cuda_profiler_api_13.3',
  'cudart_13.3',
  'cufft_13.3',
  'cufft_dev_13.3',
  'cuobjdump_13.3',
  'cupti_13.3',
  'curand_13.3',
  'curand_dev_13.3',
  'cusolver_13.3',
  'cusolver_dev_13.3',
  'cusparse_13.3',
  'cusparse_dev_13.3',
  'cuxxfilt_13.3',
  'npp_13.3',
  'npp_dev_13.3',
  'nvcc_13.3',
  'nvdisasm_13.3',
  'nvfatbin_13.3',
  'nvjitlink_13.3',
  'nvjpeg_13.3',
  'nvjpeg_dev_13.3',
  'nvml_dev_13.3',
  'nvprune_13.3',
  'nvptxcompiler_13.3',
  'nvrtc_13.3',
  'nvrtc_dev_13.3',
  'nvtx_13.3',
  'nvvm_13.3',
  'opencl_13.3',
  'sanitizer_13.3',
  'thrust_13.3',
  'tileiras_13.3',
  '-n'
)
