# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

# REPLACE WITH DROP-TO-ADMIN-USER-PREFIX.ps1

# REPLACE WITH UTILITY-PREFIX.ps1

# REPLACE WITH $CudnnUrl

$CudnnLocalZipPath = "$PSScriptRoot\cudnn-windows-x86_64-8.3.2.44_cuda11.5-archive.zip"

$CudaUrl = 'https://developer.download.nvidia.com/compute/cuda/11.6.0/network_installers/cuda_11.6.0_windows_network.exe'

$CudaFeatures = 'nvcc_11.6 cuobjdump_11.6 nvprune_11.6 cupti_11.6 memcheck_11.6 nvdisasm_11.6 nvprof_11.6 ' + `
 'visual_studio_integration_11.6 visual_profiler_11.6 visual_profiler_11.6 cublas_11.6 cublas_dev_11.6 ' + `
 'cudart_11.6 cufft_11.6 cufft_dev_11.6 curand_11.6 curand_dev_11.6 cusolver_11.6 cusolver_dev_11.6 ' + `
 'cusparse_11.6 cusparse_dev_11.6 npp_11.6 npp_dev_11.6 nvrtc_11.6 nvrtc_dev_11.6 nvml_dev_11.6 ' + `
 'occupancy_calculator_11.6 thrust_11.6 '

$destination = "$env:ProgramFiles\NVIDIA GPU Computing Toolkit\CUDA\v11.6"

try {
  Write-Host 'Downloading CUDA...'
  [string]$installerPath = Get-TempFilePath -Extension 'exe'
  curl.exe -L -o $installerPath -s -S $CudaUrl
  Write-Host 'Installing CUDA...'
  $proc = Start-Process -FilePath $installerPath -ArgumentList @('-s ' + $CudaFeatures) -Wait -PassThru
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
