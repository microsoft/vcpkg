# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

# REPLACE WITH DROP-TO-ADMIN-USER-PREFIX.ps1

# REPLACE WITH UTILITY-PREFIX.ps1

$oneAPIBaseUrl = 'https://registrationcenter-download.intel.com/akdlm/IRC_NAS/19085/w_HPCKit_p_2023.0.0.25931_offline.exe'
$oneAPIHPCComponents = 'intel.oneapi.win.cpp-compiler:intel.oneapi.win.ifort-compiler'

<#
.SYNOPSIS
Installs Intel oneAPI compilers and toolsets. Examples for CI can be found here: https://github.com/oneapi-src/oneapi-ci

.DESCRIPTION
InstallInteloneAPI installs the Intel oneAPI Compiler & Toolkit with the components specified as a
:-separated list of strings in $Components.

.PARAMETER Url
The URL of the Intel Toolkit installer.

.PARAMETER Components
A :-separated list of components to install.
#>
Function InstallInteloneAPI {
  Param(
    [String]$Url,
    [String]$Components
  )

  try {
    [string]$installerPath = Get-TempFilePath -Extension 'exe'
    [string]$extractionPath = [System.IO.Path]::GetTempPath() + [System.IO.Path]::GetRandomFileName()
    Write-Host 'Downloading Intel oneAPI...to: ' $installerPath
    curl.exe -L -o $installerPath -s -S $Url
    Write-Host 'Extracting Intel oneAPI...to folder: ' $extractionPath
    $proc = Start-Process -FilePath $installerPath -ArgumentList @('-s ', '-x ', '-f ' + $extractionPath , '--log extract.log') -Wait -PassThru
    Write-Host 'Install Intel oneAPI...from folder: ' $extractionPath
    $proc = Start-Process -FilePath $extractionPath/bootstrapper.exe -ArgumentList @('-s ', '--action install', "--components=$Components" , '--eula=accept', '-p=NEED_VS2017_INTEGRATION=0', '-p=NEED_VS2019_INTEGRATION=0', '-p=NEED_VS2022_INTEGRATION=0', '--log-dir=.') -Wait -PassThru
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
    Write-Error "Failed to install Intel oneAPI! $($_.Exception.Message)"
    throw
  }
}

InstallInteloneAPI -Url $oneAPIBaseUrl -Components $oneAPIHPCComponents
