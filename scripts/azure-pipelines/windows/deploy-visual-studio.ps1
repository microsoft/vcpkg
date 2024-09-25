# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

# See https://learn.microsoft.com/en-us/visualstudio/releases/2022/release-history
# 17.11.3
$VisualStudioBootstrapperUrl = 'https://download.visualstudio.microsoft.com/download/pr/030a0062-e1e5-4a6c-9385-a6f146dbd9db/85d31bd580a0b36936164315bd423d22af90f90d180a540ef4245522e0bcd085/vs_Enterprise.exe'
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
  'Microsoft.VisualStudio.Component.Windows11SDK.22621',
  'Microsoft.VisualStudio.Component.Windows10SDK.20348',
  'Microsoft.Net.Component.4.8.SDK',
  'Microsoft.Net.Component.4.7.2.TargetingPack',
  'Microsoft.Component.NetFX.Native',
  'Microsoft.VisualStudio.Component.VC.Llvm.ClangToolset',
  'Microsoft.VisualStudio.Component.VC.Llvm.Clang',
  'Microsoft.VisualStudio.ComponentGroup.UWP.VC.BuildTools',
  'Microsoft.VisualStudio.Component.VC.CMake.Project'
)

$vsArgs = @('--quiet', '--norestart', '--wait', '--nocache')
foreach ($workload in $Workloads) {
  $vsArgs += '--add'
  $vsArgs += $workload
}

DownloadAndInstall -Name 'Visual Studio' -Url $VisualStudioBootstrapperUrl -Args $vsArgs
