# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

# REPLACE WITH DROP-TO-ADMIN-USER-PREFIX.ps1

# REPLACE WITH UTILITY-PREFIX.ps1

$WindowsWDKUrl = 'https://go.microsoft.com/fwlink/?linkid=2128854'

<#
.SYNOPSIS
Installs Windows WDK version 2004

.DESCRIPTION
Downloads the Windows WDK installer located at $Url, and installs it with the
correct flags.

.PARAMETER Url
The URL of the installer.
#>
Function InstallWindowsWDK {
  Param(
    [String]$Url
  )

  try {
    Write-Host 'Downloading Windows WDK...'
    [string]$installerPath = Get-TempFilePath -Extension 'exe'
    curl.exe -L -o $installerPath -s -S $Url
    Write-Host 'Installing Windows WDK...'
    $proc = Start-Process -FilePath $installerPath -ArgumentList @('/features', '+', '/q') -Wait -PassThru
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
    Write-Error "Failed to install Windows WDK! $($_.Exception.Message)"
    throw
  }
}

InstallWindowsWDK -Url $WindowsWDKUrl
