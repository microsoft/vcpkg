# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

# REPLACE WITH DROP-TO-ADMIN-USER-PREFIX.ps1

# REPLACE WITH UTILITY-PREFIX.ps1

# REPLACE WITH $CudnnUrl

$CudnnLocalZipPath = "$PSScriptRoot\cudnn-windows-x86_64-8.8.1.3_cuda12-archive.zip"

$CudaUrl = 'https://developer.download.nvidia.com/compute/cuda/12.1.0/network_installers/cuda_12.1.0_windows_network.exe'

# https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/index.html
# Intentionally omitted:
#  demo_suite_12.1
#  documentation_12.1
#  nvvm_samples_12.1
#  Display.Driver

$CudaInstallerArgs = @(
  '-s',
  'cublas_12.1',
  'cublas_dev_12.1',
  'cuda_profiler_api_12.1',
  'cudart_12.1',
  'cufft_12.1',
  'cufft_dev_12.1',
  'cuobjdump_12.1',
  'cupti_12.1',
  'curand_12.1',
  'curand_dev_12.1',
  'cusolver_12.1',
  'cusolver_dev_12.1',
  'cusparse_12.1',
  'cusparse_dev_12.1',
  'cuxxfilt_12.1',
  'npp_12.1',
  'npp_dev_12.1',
  'nsight_compute_12.1',
  'nsight_systems_12.1',
  'nsight_vse_12.1',
  'nvcc_12.1',
  'nvdisasm_12.1',
  'nvjitlink_12.1',
  'nvjpeg_12.1',
  'nvjpeg_dev_12.1',
  'nvml_dev_12.1',
  'nvprof_12.1',
  'nvprune_12.1',
  'nvrtc_12.1',
  'nvrtc_dev_12.1',
  'nvtx_12.1',
  'occupancy_calculator_12.1',
  'opencl_12.1',
  'sanitizer_12.1',
  'thrust_12.1',
  'visual_profiler_12.1',
  'visual_studio_integration_12.1'
)

$destination = "$env:ProgramFiles\NVIDIA GPU Computing Toolkit\CUDA\v12.1"

try {
  Write-Host 'Downloading CUDA...'
  [string]$installerPath = Get-TempFilePath -Extension 'exe'
  curl.exe -L -o $installerPath -s -S $CudaUrl
  Write-Host 'Installing CUDA...'
  $proc = Start-Process -FilePath $installerPath -ArgumentList $CudaInstallerArgs -Wait -PassThru
  $exitCode = $proc.ExitCode
  if ($exitCode -eq 0) {
    Write-Host 'Installation successful!'
  }
  else {
    Write-Error "Installation failed! Exited with $exitCode."
    throw
  }
}
catch {
  Write-Error "Failed to install CUDA! $($_.Exception.Message)"
  throw
}

try {
  if ([string]::IsNullOrWhiteSpace($CudnnUrl)) {
    if (-Not (Test-Path $CudnnLocalZipPath)) {
      throw "CUDNN zip ($CudnnLocalZipPath) was missing, please download from NVidia and place next to this script."
    }

    $cudnnZipPath = $CudnnLocalZipPath
  } else {
    Write-Host 'Downloading CUDNN...'
    $cudnnZipPath = Get-TempFilePath -Extension 'zip'
    curl.exe -L -o $cudnnZipPath -s -S $CudnnUrl
  }

  Write-Host "Installing CUDNN to $destination..."
  tar.exe -xvf "$cudnnZipPath" --strip 1 --directory "$destination"
  Write-Host 'Installation successful!'
}
catch {
  Write-Error "Failed to install CUDNN! $($_.Exception.Message)"
  throw
}
