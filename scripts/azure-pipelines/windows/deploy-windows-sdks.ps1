# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

# REPLACE WITH DROP-TO-ADMIN-USER-PREFIX.ps1

# REPLACE WITH UTILITY-PREFIX.ps1

<#
.SYNOPSIS
Installs Windows PSDK/WDK

.DESCRIPTION
Downloads the Windows PSDK/DDK installer located at $Url, and installs it with the
correct flags.

.PARAMETER Url
The URL of the installer.
#>
Function InstallWindowsDK {
  Param(
    [String]$Url
  )

  try {
    Write-Host "Downloading Windows PSDK or DDK $Url..."
    [string]$installerPath = Get-TempFilePath -Extension 'exe'
    curl.exe -L -o $installerPath -s -S $Url
    Write-Host 'Installing...'
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
    Write-Error "Failed to install Windows PSDK or DDK! $($_.Exception.Message)"
    throw
  }
}

# Windows 10 WDK,  version 2004
InstallWindowsDK 'https://go.microsoft.com/fwlink/?linkid=2128854'
