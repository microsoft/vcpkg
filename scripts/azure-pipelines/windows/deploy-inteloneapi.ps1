# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}


[string]$oneAPIBaseUrl
if ([string]::IsNullOrEmpty($SasToken)) {
  Write-Host 'Downloading from the Internet'
  $oneAPIBaseUrl = 'https://registrationcenter-download.intel.com/akdlm/IRC_NAS/c95a3b26-fc45-496c-833b-df08b10297b9/w_HPCKit_p_2024.1.0.561_offline.exe'
} else {
  Write-Host 'Downloading from vcpkgimageminting using SAS token'
  $SasToken = $SasToken.Replace('"', '')
  $oneAPIBaseUrl = "https://vcpkgimageminting.blob.core.windows.net/assets/w_HPCKit_p_2024.1.0.561_offline.exe?$SasToken"
}

$oneAPIHPCComponents = 'intel.oneapi.win.ifort-compiler'

$LocalName = 'w_HPCKit_p_2024.1.0.561_offline.exe'

try {
  [bool]$doRemove = $false
  [string]$LocalPath = Join-Path $PSScriptRoot $LocalName
  if (Test-Path $LocalPath) {
    Write-Host "Using local Intel oneAPI..."
  } else {
    Write-Host "Downloading Intel oneAPI..."
    $tempPath = Get-TempFilePath
    New-Item -ItemType Directory -Path $tempPath -Force
    $LocalPath = Join-Path $tempPath $LocalName
    curl.exe -L -o $LocalPath $oneAPIBaseUrl
    $doRemove = $true
  }

  [string]$extractionPath = Get-TempFilePath
  Write-Host 'Extracting Intel oneAPI...to folder: ' $extractionPath
  $proc = Start-Process -FilePath $LocalPath -ArgumentList @('-s ', '-x', '-f', $extractionPath) -Wait -PassThru
  $exitCode = $proc.ExitCode
  if ($exitCode -eq 0) {
    Write-Host 'Extraction successful!'
  } else {
    Write-Error "Extraction failed! Exited with $exitCode."
    throw
  }

  Write-Host 'Install Intel oneAPI...from folder: ' $extractionPath
  $proc = Start-Process -FilePath "$extractionPath/bootstrapper.exe" -ArgumentList @('-s ', '--action install', "--components=$oneAPIHPCComponents" , '--eula=accept', '-p=NEED_VS2017_INTEGRATION=0', '-p=NEED_VS2019_INTEGRATION=0', '-p=NEED_VS2022_INTEGRATION=0', '--log-dir=.') -Wait -PassThru
  $exitCode = $proc.ExitCode
  if ($exitCode -eq 0) {
    Write-Host 'Installation successful!'
  } elseif ($exitCode -eq 3010) {
    Write-Host 'Installation successful! Exited with 3010 (ERROR_SUCCESS_REBOOT_REQUIRED).'
  } else {
    Write-Error "Installation failed! Exited with $exitCode."
  }

  if ($doRemove) {
    Remove-Item -Path $LocalPath -Force
  }
} catch {
  Write-Error "Installation failed! Exception: $($_.Exception.Message)"
}
