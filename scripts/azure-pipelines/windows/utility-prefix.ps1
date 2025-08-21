# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

<#
.SYNOPSIS
Gets a random file path in the temp directory.

.DESCRIPTION
Get-TempFilePath takes an extension, and returns a path with a random
filename component in the temporary directory with that extension.

.PARAMETER Extension
The extension to use for the path.
#>
Function Get-TempFilePath {
  Param(
    [String]$Extension
  )

  $tempPath = [System.IO.Path]::GetTempPath()
  $tempName = [System.IO.Path]::GetRandomFileName()
  if (-not [String]::IsNullOrWhiteSpace($Extension)) {
    $tempName = $tempName + '.' + $Extension
  }
  return Join-Path $tempPath $tempName
}

<#
.SYNOPSIS
Download and install a component.

.DESCRIPTION
DownloadAndInstall downloads an executable from the given URL, and runs it with the given command-line arguments.

.PARAMETER Name
The name of the component, to be displayed in logging messages.

.PARAMETER Url
The URL of the installer.

.PARAMETER Args
The command-line arguments to pass to the installer.
#>
Function DownloadAndInstall {
  [CmdletBinding(PositionalBinding=$false)]
  Param(
    [Parameter(Mandatory)][String]$Name,
    [Parameter(Mandatory)][String]$Url,
    [Parameter(Mandatory)][String[]]$Args,
    [String]$LocalName = $null
  )

  try {
    if ([string]::IsNullOrWhiteSpace($LocalName)) {
      $LocalName = [uri]::new($Url).Segments[-1]
    }

    [bool]$doRemove = $false
    [string]$LocalPath = Join-Path $PSScriptRoot $LocalName
    if (Test-Path $LocalPath) {
      Write-Host "Using local $Name..."
    } else {
      Write-Host "Downloading $Name..."
      $tempPath = Get-TempFilePath
      New-Item -ItemType Directory -Path $tempPath -Force | Out-Null
      $LocalPath = Join-Path $tempPath $LocalName
      curl.exe --fail -L -o $LocalPath $Url
      if (-Not $?) {
        Write-Error 'Download failed!'
      }
      $doRemove = $true
    }

    Write-Host "Installing $Name..."
    $proc = Start-Process -FilePath $LocalPath -ArgumentList $Args -Wait -PassThru
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
}

<#
.SYNOPSIS
Download and install a zip file component.

.DESCRIPTION
DownloadAndUnzip downloads a zip from the given URL, and extracts it to the indicated path.

.PARAMETER Name
The name of the component, to be displayed in logging messages.

.PARAMETER Url
The URL of the zip to download.

.PARAMETER Destination
The location to which the zip should be extracted
#>
Function DownloadAndUnzip {
  [CmdletBinding(PositionalBinding=$false)]
  Param(
    [Parameter(Mandatory)][String]$Name,
    [Parameter(Mandatory)][String]$Url,
    [Parameter(Mandatory)][String]$Destination
  )

  try {
    $fileName = [uri]::new($Url).Segments[-1]
    if ([string]::IsNullOrWhiteSpace($LocalName)) {
      $LocalName = $fileName
    }

    [string]$zipPath
    [bool]$doRemove = $false
    [string]$LocalPath = Join-Path $PSScriptRoot $LocalName
    if (Test-Path $LocalPath) {
      Write-Host "Using local $Name..."
      $zipPath = $LocalPath
    } else {
      $tempPath = Get-TempFilePath
      New-Item -ItemType Directory -Path $tempPath -Force | Out-Null
      $zipPath = Join-Path $tempPath $LocalName
      Write-Host "Downloading $Name ( $Url -> $zipPath )..."
      curl.exe --fail -L -o $zipPath $Url
      if (-Not $?) {
        Write-Error 'Download failed!'
      }
      $doRemove = $true
    }

    Write-Host "Installing $Name to $Destination..."
    & tar.exe -xvf $zipPath --strip 1 --directory $Destination
    if ($LASTEXITCODE -eq 0) {
      Write-Host 'Installation successful!'
    } else {
      Write-Error "Installation failed! Exited with $LASTEXITCODE."
    }

    if ($doRemove) {
      Remove-Item -Path $zipPath -Force
    }
  } catch {
    Write-Error "Installation failed! Exception: $($_.Exception.Message)"
  }
}
