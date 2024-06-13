# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

# REPLACE WITH DROP-TO-ADMIN-USER-PREFIX.ps1

# REPLACE WITH UTILITY-PREFIX.ps1

# See https://learn.microsoft.com/en-us/visualstudio/releases/2022/release-history
$VisualStudioBootstrapperUrl = 'https://download.visualstudio.microsoft.com/download/pr/a8a3940c-d415-4078-8df8-6af787f56dfa/ff486670bce61323e52b208ecbb71dc05b034c8bf156d0b7bfc0ad67b2611445/vs_Enterprise.exe'
$Workloads = @(
  'Microsoft.VisualStudio.Workload.NativeDesktop',
  'Microsoft.VisualStudio.Workload.Universal',
  'Microsoft.VisualStudio.Component.UWP.VC.ARM64',
  'Microsoft.VisualStudio.Component.VC.Tools.x86.x64',
  'Microsoft.VisualStudio.Component.VC.Tools.ARM64',
  'Microsoft.VisualStudio.Component.VC.ASAN',
  'Microsoft.VisualStudio.Component.VC.ATL',
  'Microsoft.VisualStudio.Component.VC.ATLMFC',
  'Microsoft.VisualStudio.Component.VC.ATL.ARM64',
  'Microsoft.VisualStudio.Component.VC.MFC.ARM64',
  "Microsoft.VisualStudio.Component.Windows11SDK.22621",
  "Microsoft.VisualStudio.Component.Windows10SDK.20348",
  'Microsoft.Net.Component.4.8.SDK',
  'Microsoft.Net.Component.4.7.2.TargetingPack',
  'Microsoft.Component.NetFX.Native',
  'Microsoft.VisualStudio.Component.VC.Llvm.ClangToolset',
  'Microsoft.VisualStudio.Component.VC.Llvm.Clang',
  'Microsoft.VisualStudio.ComponentGroup.UWP.VC.BuildTools',
  'Microsoft.VisualStudio.Component.VC.CMake.Project'
)

<#
.SYNOPSIS
Install Visual Studio.

.DESCRIPTION
InstallVisualStudio takes the $Workloads array, and installs it with the
installer that's pointed at by $BootstrapperUrl.

.PARAMETER Workloads
The set of VS workloads to install.

.PARAMETER BootstrapperUrl
The URL of the Visual Studio installer, i.e. one of vs_*.exe.

.PARAMETER InstallPath
The path to install Visual Studio at.

.PARAMETER Nickname
The nickname to give the installation.
#>
Function InstallVisualStudio {
  Param(
    [String[]]$Workloads,
    [String]$BootstrapperUrl,
    [String]$InstallPath = $null,
    [String]$Nickname = $null
  )

  try {
    Write-Host 'Downloading Visual Studio...'
    [string]$bootstrapperExe = Get-TempFilePath -Extension 'exe'
    curl.exe -L -o $bootstrapperExe -s -S $BootstrapperUrl
    Write-Host 'Installing Visual Studio...'
    $vsArgs = @('/c', $bootstrapperExe, '--quiet', '--norestart', '--wait', '--nocache')
    foreach ($workload in $Workloads) {
      $vsArgs += '--add'
      $vsArgs += $workload
    }

    if (-not ([String]::IsNullOrWhiteSpace($InstallPath))) {
      $vsArgs += '--installpath'
      $vsArgs += $InstallPath
    }

    if (-not ([String]::IsNullOrWhiteSpace($Nickname))) {
      $vsArgs += '--nickname'
      $vsArgs += $Nickname
    }

    $proc = Start-Process -FilePath cmd.exe -ArgumentList $vsArgs -Wait -PassThru
    PrintMsiExitCodeMessage $proc.ExitCode
  }
  catch {
    Write-Error "Failed to install Visual Studio! $($_.Exception.Message)"
    throw
  }
}

InstallVisualStudio -Workloads $Workloads -BootstrapperUrl $VisualStudioBootstrapperUrl -Nickname 'Stable'
