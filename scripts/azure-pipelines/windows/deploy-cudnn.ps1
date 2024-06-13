# REPLACE WITH UTILITY-PREFIX.ps1

# REPLACE WITH CudnnUrl

$destination = "$env:ProgramFiles\NVIDIA GPU Computing Toolkit\CUDA\v12.1"

$CudnnLocalZipPath = "$PSScriptRoot\cudnn-windows-x86_64-8.8.1.3_cuda12-archive.zip"

try {
  if (Test-Path $CudnnLocalZipPath) {
    $cudnnZipPath = $CudnnLocalZipPath
  } else {
    Write-Host 'Attempting to download cudnn. If this fails, you need to agree to NVidia''s EULA, download cudnn, and place it next to this script.'
    $cudnnZipPath = Get-TempFilePath -Extension 'zip'
    & curl.exe -L -o $cudnnZipPath $CudnnUrl
    if ($LASTEXITCODE -ne 0) {
      throw 'Failed to download cudnn!'
    }
  }

  Write-Host "Installing CUDNN to $destination..."
  tar.exe -xvf "$cudnnZipPath" --strip 1 --directory "$destination"
  Write-Host 'Installation successful!'
}
catch {
  Write-Error "Failed to install CUDNN! $($_.Exception.Message)"
  throw
}
