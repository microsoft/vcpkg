# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

if (Test-Path -LiteralPath "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

$CudaUrl = Get-AssetUrl `
  -InternetUrl 'https://developer.download.nvidia.com/compute/cuda/13.4.3/local_installers/cuda_13.4.3_windows_x86_64.exe' `
  -BlobAssetName 'cuda_13.4.3_windows_x86_64.exe'

# https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/index.html
# On version updates, extract the package manifests from the installer with:
#  7z x cuda_<version>_windows_x86_64.exe -o<output> -ir!*.nvi
# Each manifest whose customInstallTree/treeNode has accessibility="selectable" names a valid package
# in its root <nvi name="..."> element. Compare those names with both lists below; NVIDIA changes the
# package names and composition between releases. Confirm every omission is still related to drivers,
# documentation, or Visual Studio.
#
# Intentionally omitted due to being Visual Studio / GUI features:
#  ctadvisor_13.4
#  nsight_compute_13.4
#  nsight_systems_13.4
#  nsight_vse_13.4
#  visual_studio_integration_13.4
# Intentionally omitted due to being documentation:
#  documentation_13.4
#  occupancy_calculator_13.4 (this is named like a tool but listed as 'documentation' in the installer)
# (Drivers used to be omitted but as of CUDA 13 they no longer seem to be in the CUDA installer)
DownloadAndInstall -Url $CudaUrl -Args @(
  '-s',
  'crt_13.4',
  'cublas_13.4',
  'cublas_dev_13.4',
  'cublas_cross_13.4',
  'cuda_profiler_api_13.4',
  'cudart_13.4',
  'cudart_cross_13.4',
  'cufft_13.4',
  'cufft_dev_13.4',
  'cufft_cross_13.4',
  'cuobjdump_13.4',
  'cupti_13.4',
  'cupti_cross_13.4',
  'curand_13.4',
  'curand_dev_13.4',
  'curand_cross_13.4',
  'cusolver_13.4',
  'cusolver_dev_13.4',
  'cusolver_cross_13.4',
  'cusparse_13.4',
  'cusparse_dev_13.4',
  'cusparse_cross_13.4',
  'cuxxfilt_13.4',
  'cuxxfilt_cross_13.4',
  'npp_13.4',
  'npp_dev_13.4',
  'npp_cross_13.4',
  'nvcc_13.4',
  'nvcc_cross_13.4',
  'nvdisasm_13.4',
  'nvfatbin_13.4',
  'nvfatbin_cross_13.4',
  'nvjitlink_13.4',
  'nvjitlink_cross_13.4',
  'nvjpeg_13.4',
  'nvjpeg_dev_13.4',
  'nvjpeg_cross_13.4',
  'nvml_dev_13.4',
  'nvml_dev_cross_13.4',
  'nvprune_13.4',
  'nvptxcompiler_13.4',
  'nvptxcompiler_cross_13.4',
  'nvrtc_13.4',
  'nvrtc_dev_13.4',
  'nvrtc_cross_13.4',
  'nvtx_13.4',
  'nvvm_13.4',
  'opencl_13.4',
  'opencl_cross_13.4',
  'sanitizer_13.4',
  'thrust_13.4',
  'tileiras_13.4',
  '-n'
)
