# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

# REPLACE WITH DROP-TO-ADMIN-USER-PREFIX.ps1

# REPLACE WITH UTILITY-PREFIX.ps1

# REPLACE WITH $CudnnUrl

$CudnnLocalZipPath = "$PSScriptRoot\cudnn-11.2-windows-x64-v8.1.1.33.zip"

$CudaUrl = 'https://developer.download.nvidia.com/compute/cuda/11.3.0/network_installers/cuda_11.3.0_win10_network.exe'

$CudaFeatures = 'nvcc_11.3 cuobjdump_11.3 nvprune_11.3 cupti_11.3 memcheck_11.3 nvdisasm_11.3 nvprof_11.3 ' + `
 'visual_studio_integration_11.3 visual_profiler_11.3 visual_profiler_11.3 cublas_11.3 cublas_dev_11.3 ' + `
 'cudart_11.3 cufft_11.3 cufft_dev_11.3 curand_11.3 curand_dev_11.3 cusolver_11.3 cusolver_dev_11.3 ' + `
 'cusparse_11.3 cusparse_dev_11.3 npp_11.3 npp_dev_11.3 nvrtc_11.3 nvrtc_dev_11.3 nvml_dev_11.3 ' + `
 'occupancy_calculator_11.3 thrust_11.3 '

$destination = "$env:ProgramFiles\NVIDIA GPU Computing Toolkit\CUDA\v11.3"

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
