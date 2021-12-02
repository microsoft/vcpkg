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

  if ([String]::IsNullOrWhiteSpace($Extension)) {
    throw 'Missing Extension'
  }

  $tempPath = [System.IO.Path]::GetTempPath()
  $tempName = [System.IO.Path]::GetRandomFileName() + '.' + $Extension
  return Join-Path $tempPath $tempName
}

<#
.SYNOPSIS
Writes a message to the screen depending on ExitCode.

.DESCRIPTION
Since msiexec can return either 0 or 3010 successfully, in both cases
we write that installation succeeded, and which exit code it exited with.
If msiexec returns anything else, we write an error.

.PARAMETER ExitCode
The exit code that msiexec returned.
#>
Function PrintMsiExitCodeMessage {
  Param(
    $ExitCode
  )

  # 3010 is probably ERROR_SUCCESS_REBOOT_REQUIRED
  if ($ExitCode -eq 0 -or $ExitCode -eq 3010) {
    Write-Host "Installation successful! Exited with $ExitCode."
  }
  else {
    Write-Error "Installation failed! Exited with $ExitCode."
    throw
  }
}

<#
.SYNOPSIS
Install a .msi file.

.DESCRIPTION
InstallMSI takes a url where an .msi lives, and installs that .msi to the system.

.PARAMETER Name
The name of the thing to install.

.PARAMETER Url
The URL at which the .msi lives.
#>
Function InstallMSI {
  Param(
    [String]$Name,
    [String]$Url
  )

  try {
    Write-Host "Downloading $Name..."
    [string]$msiPath = Get-TempFilePath -Extension 'msi'
    curl.exe -L -o $msiPath -s -S $Url
    Write-Host "Installing $Name..."
    $args = @('/i', $msiPath, '/norestart', '/quiet', '/qn')
    $proc = Start-Process -FilePath 'msiexec.exe' -ArgumentList $args -Wait -PassThru
    PrintMsiExitCodeMessage $proc.ExitCode
  }
  catch {
    Write-Error "Failed to install $Name! $($_.Exception.Message)"
    throw
  }
}

<#
.SYNOPSIS
Unpacks a zip file to $Dir.

.DESCRIPTION
InstallZip takes a URL of a zip file, and unpacks the zip file to the directory
$Dir.

.PARAMETER Name
The name of the tool being installed.

.PARAMETER Url
The URL of the zip file to unpack.

.PARAMETER Dir
The directory to unpack the zip file to.
#>
Function InstallZip {
  Param(
    [String]$Name,
    [String]$Url,
    [String]$Dir
  )

  try {
    Write-Host "Downloading $Name..."
    [string]$zipPath = Get-TempFilePath -Extension 'zip'
    curl.exe -L -o $zipPath -s -S $Url
    Write-Host "Installing $Name..."
    Expand-Archive -Path $zipPath -DestinationPath $Dir -Force
  }
  catch {
    Write-Error "Failed to install $Name! $($_.Exception.Message)"
    throw
  }
}
