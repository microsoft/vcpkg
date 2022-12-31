# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

# REPLACE WITH DROP-TO-ADMIN-USER-PREFIX.ps1

# REPLACE WITH UTILITY-PREFIX.ps1

# Seems like only the HPC kit is really needed?
#$oneAPIBaseUrl = 'https://registrationcenter-download.intel.com/akdlm/irc_nas/17768/w_BaseKit_p_2021.2.0.2871_offline.exe'
$oneAPIHPCUrl = 'https://registrationcenter-download.intel.com/akdlm/irc_nas/18578/w_HPCKit_p_2022.1.3.145_offline.exe'

# Possible oneAPI Base components:
#intel.oneapi.win.vtune           2021.1.1-68           true      Intel® VTune(TM) Profiler
#intel.oneapi.win.tbb.devel       2021.1.1-133          true      Intel® oneAPI Threading Building Blocks
#intel.oneapi.win.dnnl            2021.1.1-44           true      Intel® oneAPI Deep Neural Network Library
#intel.oneapi.win.mkl.devel       2021.1.1-52           true      Intel® oneAPI Math Kernel Library
#intel.oneapi.win.vpl             2021.1.1-76           true      Intel® oneAPI Video Processing Library
#intel.oneapi.win.dpcpp_debugger  10.0.0-2213           true      Intel® Distribution for GDB*
#intel.oneapi.win.ipp.devel       2021.1.1-47           true      Intel® Integrated Performance Primitives
#intel.oneapi.win.ippcp           2021.1.1-53           true      Intel® Integrated Performance Primitives Cryptography
#intel.oneapi.win.dpcpp-compiler  2021.1.1-191          true      Intel® oneAPI DPC++/C++ Compiler
#intel.oneapi.win.dpcpp-library   2021.1.1-191          true      Intel® oneAPI DPC++ Library
#intel.oneapi.win.dpcpp_ct.common 2021.1.1-54           true      Intel® DPC++ Compatibility Tool
#intel.oneapi.win.dal.devel       2021.1.1-71           true      Intel® oneAPI Data Analytics Library
#intel.oneapi.win.python3         2021.1.1-46           true      Intel® Distribution for Python*
#intel.oneapi.win.advisor         2021.1.1-53           true      Intel® Advisor
#$oneAPIBaseComponents = 'intel.oneapi.win.dpcpp-compiler:intel.oneapi.win.dpcpp-library:intel.oneapi.win.mkl.devel:intel.oneapi.win.ipp.devel:intel.oneapi.win.ippcp:intel.oneapi.win.dal.devel:intel.oneapi.win.dnnl:intel.oneapi.win.vpl:intel.oneapi.win.tbb.devel'
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

InstallInteloneAPI -Url $oneAPIHPCUrl -Components $oneAPIHPCComponents
