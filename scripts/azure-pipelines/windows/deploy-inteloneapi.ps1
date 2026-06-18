# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path -LiteralPath "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

$LocalName = 'intel-oneapi-hpc-toolkit-2025.3.1.54_offline.exe'
$oneAPIBaseUrl = Get-AssetUrl `
  -SasToken $SasToken `
  -InternetUrl "https://registrationcenter-download.intel.com/akdlm/IRC_NAS/36f868e9-84b3-4b4f-90ef-ca84092cae6a/$LocalName" `
  -BlobAssetName $LocalName

$oneAPIHPCComponents = 'intel.oneapi.win.ifort-compiler'

try {
  $installer = Get-LocalOrDownloadedFile -Url $oneAPIBaseUrl -LocalName $LocalName
  [string]$LocalPath = $installer.Path

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

  if ($installer.Temporary) {
    Remove-Item -LiteralPath $LocalPath -Force
  }
} catch {
  Write-Error "Installation failed! Exception: $($_.Exception.Message)"
}
