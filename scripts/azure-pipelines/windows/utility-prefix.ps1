# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

$UseManagedIdentity = $false

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
Gets the download URL for an image asset.

.DESCRIPTION
Get-AssetUrl returns the upstream URL unless UseManagedIdentity is specified,
in which case it returns the corresponding vcpkgimageminting asset URL.

.PARAMETER InternetUrl
The upstream download URL.

.PARAMETER BlobAssetName
The asset file name in the vcpkgimageminting blob container.
#>
Function Get-AssetUrl {
  [CmdletBinding(PositionalBinding=$false)]
  Param(
    [Parameter(Mandatory)][uri]$InternetUrl,
    [Parameter(Mandatory)][String]$BlobAssetName
  )

  if (-not $UseManagedIdentity) {
    return $InternetUrl
  }

  return [uri]"https://vcpkgimageminting.blob.core.windows.net/assets/$([uri]::EscapeDataString($BlobAssetName))"
}

<#
.SYNOPSIS
Describes where installation content will be sourced from.

.DESCRIPTION
Get-ContentSourceDescription returns $null for a local copy, or a short string
describing the remote source when the content must be downloaded.

.PARAMETER LocalPath
The path to a local copy of the content, if present.

.PARAMETER Url
The URL to download when no local copy is available.
#>
Function Get-ContentSourceDescription {
  [CmdletBinding(PositionalBinding=$false)]
  Param(
    [Parameter(Mandatory)][System.IO.FileInfo]$LocalPath,
    [Parameter(Mandatory)][uri]$Url
  )

  if (Test-Path -LiteralPath $LocalPath) {
    return $null
  }

  if ($Url.Host -ieq 'vcpkgimageminting.blob.core.windows.net') {
    return 'vcpkgimageminting using managed identity'
  }

  return 'the internet'
}

<#
.SYNOPSIS
Gets a local file path for an asset, downloading it if necessary.

.DESCRIPTION
Get-LocalOrDownloadedFile returns a local file when it exists next to the
script, or downloads the content to a temporary location and returns that
path instead.

.PARAMETER Url
The URL of the asset to acquire.

.PARAMETER LocalName
The optional local file name to look for next to the script.
#>
Function Get-LocalOrDownloadedFile {
  [CmdletBinding(PositionalBinding=$false)]
  Param(
    [Parameter(Mandatory)][uri]$Url,
    [String]$LocalName = $null
  )

  if ([string]::IsNullOrWhiteSpace($LocalName)) {
    $LocalName = Split-Path -Leaf ($Url.LocalPath)
  }

  [string]$LocalPath = Join-Path $PSScriptRoot $LocalName
  $contentSource = Get-ContentSourceDescription -LocalPath $LocalPath -Url $Url
  if ($contentSource) {
    Write-Host "Downloading $LocalName from $contentSource..."
    $tempPath = Get-TempFilePath
    New-Item -ItemType Directory -Path $tempPath -Force | Out-Null
    $downloadPath = Join-Path $tempPath $LocalName

    if ($Url.Host -ieq 'vcpkgimageminting.blob.core.windows.net') {
      $tokenResponseJson = curl.exe `
        --fail `
        --silent `
        --show-error `
        --noproxy '*' `
        --header 'Metadata: true' `
        'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fstorage.azure.com%2F'
      if ($LASTEXITCODE -ne 0) {
        throw 'Failed to acquire an Azure Storage access token from IMDS.'
      }

      $storageAccessToken = ($tokenResponseJson | ConvertFrom-Json).access_token
      if ([string]::IsNullOrWhiteSpace($storageAccessToken)) {
        throw 'IMDS returned an empty Azure Storage access token.'
      }

      curl.exe `
        --fail `
        --location `
        --show-error `
        --header "Authorization: Bearer $storageAccessToken" `
        --header 'x-ms-version: 2023-11-03' `
        --output $downloadPath `
        $Url
    } else {
      curl.exe --fail --location --show-error --output $downloadPath $Url
    }

    if ($LASTEXITCODE -ne 0) {
      throw "Failed to download $LocalName."
    }

    return [pscustomobject]@{
      Path = $downloadPath
      Temporary = $true
    }
  }

  Write-Host "Using local copy of $LocalName..."
  return [pscustomobject]@{
    Path = $LocalPath
    Temporary = $false
  }
}

<#
.SYNOPSIS
Download and install a component.

.DESCRIPTION
DownloadAndInstall downloads an executable from the given URL, and runs it with the given command-line arguments.

.PARAMETER Url
The URL of the installer.

.PARAMETER Args
The command-line arguments to pass to the installer.
#>
Function DownloadAndInstall {
  [CmdletBinding(PositionalBinding=$false)]
  Param(
    [Parameter(Mandatory)][uri]$Url,
    [Parameter(Mandatory)][String[]]$Args,
    [String]$LocalName = $null
  )

  try {
    $installer = Get-LocalOrDownloadedFile -Url $Url -LocalName $LocalName
    $installerName = Split-Path -Path $installer.Path -Leaf

    Write-Host "Installing $installerName..."
    $proc = Start-Process -FilePath $installer.Path -ArgumentList $Args -Wait -PassThru
    $exitCode = $proc.ExitCode

    if ($exitCode -eq 0) {
      Write-Host 'Installation successful!'
    } elseif ($exitCode -eq 3010) {
      Write-Host 'Installation successful! Exited with 3010 (ERROR_SUCCESS_REBOOT_REQUIRED).'
    } else {
      Write-Error "Installation failed! Exited with $exitCode."
    }

    if ($installer.Temporary) {
      Remove-Item -LiteralPath $installer.Path -Force
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

.PARAMETER Url
The URL of the zip to download.

.PARAMETER Destination
The location to which the zip should be extracted
#>
Function DownloadAndUnzip {
  [CmdletBinding(PositionalBinding=$false)]
  Param(
    [Parameter(Mandatory)][uri]$Url,
    [Parameter(Mandatory)][System.IO.DirectoryInfo]$Destination,
    [switch]$StripRootDirectory,
    [String]$LocalName = $null
  )

  try {
    $zip = Get-LocalOrDownloadedFile -Url $Url -LocalName $LocalName
    $zipName = Split-Path -Path $zip.Path -Leaf

    Write-Host "Installing $zipName to $Destination..."
    if ($StripRootDirectory) {
      & tar.exe -xvf $zip.Path --strip 1 --directory $Destination
    } else {
      & tar.exe -xvf $zip.Path --directory $Destination
    }

    if ($LASTEXITCODE -eq 0) {
      Write-Host 'Installation successful!'
    } else {
      Write-Error "Installation failed! Exited with $LASTEXITCODE."
    }

    if ($zip.Temporary) {
      Remove-Item -LiteralPath $zip.Path -Force
    }
  } catch {
    Write-Error "Installation failed! Exception: $($_.Exception.Message)"
  }
}
