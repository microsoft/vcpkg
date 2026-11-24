# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

if (Test-Path -LiteralPath "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

$CudaUrl = Get-AssetUrl `
  -InternetUrl 'https://developer.download.nvidia.com/compute/cuda/13.5.0/local_installers/cuda_13.5.0_windows_x86_64.exe' `
  -BlobAssetName 'cuda_13.5.0_windows_x86_64.exe'

# https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/index.html
# On version updates, extract the package manifests from the installer with:
#  7z x cuda_<version>_windows_x86_64.exe -o<output> -ir!*.nvi
# Each manifest whose customInstallTree/treeNode has accessibility="selectable" names a valid package
# in its root <nvi name="..."> element. Compare those names with both lists below; NVIDIA changes the
# package names and composition between releases. Confirm every omission is still related to drivers,
# documentation, or Visual Studio.
#
# Intentionally omitted due to being Visual Studio / GUI features:
#  ctadvisor_13.5
#  nsight_compute_13.5
#  nsight_systems_13.5
#  nsight_vse_13.5
#  visual_studio_integration_13.5
# (Drivers used to be omitted but as of CUDA 13 they no longer seem to be in the CUDA installer)
DownloadAndInstall -Url $CudaUrl -Args @(
  '-s',
  'cccl_13.5',
  'crt_13.5',
  'cublas_13.5',
  'cublas_dev_13.5',
  'cuda_profiler_api_13.5',
  'cudart_13.5',
  'cufft_13.5',
  'cufft_dev_13.5',
  'cuobjdump_13.5',
  'cupti_13.5',
  'curand_13.5',
  'curand_dev_13.5',
  'cusolver_13.5',
  'cusolver_dev_13.5',
  'cusparse_13.5',
  'cusparse_dev_13.5',
  'cuxxfilt_13.5',
  'npp_13.5',
  'npp_dev_13.5',
  'nvcc_13.5',
  'nvdisasm_13.5',
  'nvfatbin_13.5',
  'nvjitlink_13.5',
  'nvjpeg_13.5',
  'nvjpeg_dev_13.5',
  'nvml_dev_13.5',
  'nvprune_13.5',
  'nvptxcompiler_13.5',
  'nvrtc_13.5',
  'nvrtc_dev_13.5',
  'nvtx_13.5',
  'nvvm_13.5',
  'opencl_13.5',
  'sanitizer_13.5',
  'tileiras_13.5',
  '-n'
)
