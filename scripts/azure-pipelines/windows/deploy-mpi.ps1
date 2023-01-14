# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

# REPLACE WITH DROP-TO-ADMIN-USER-PREFIX.ps1

# REPLACE WITH UTILITY-PREFIX.ps1

$MpiUrl = 'https://download.microsoft.com/download/a/5/2/a5207ca5-1203-491a-8fb8-906fd68ae623/msmpisetup.exe'

<#
.SYNOPSIS
Installs MPI

.DESCRIPTION
Downloads the MPI installer located at $Url, and installs it with the
correct flags.

.PARAMETER Url
The URL of the installer.
#>
Function InstallMpi {
  Param(
    [String]$Url
  )

  try {
    Write-Host 'Downloading MPI...'
    [string]$installerPath = Get-TempFilePath -Extension 'exe'
    curl.exe -L -o $installerPath -s -S $Url
    Write-Host 'Installing MPI...'
    $proc = Start-Process -FilePath $installerPath -ArgumentList @('-force', '-unattend') -Wait -PassThru
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
    Write-Error "Failed to install MPI! $($_.Exception.Message)"
    throw
  }
}

InstallMpi -Url $MpiUrl
