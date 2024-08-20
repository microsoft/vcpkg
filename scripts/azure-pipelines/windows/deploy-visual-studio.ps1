# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

# See https://learn.microsoft.com/en-us/visualstudio/releases/2022/release-history
# 17.8.12
$VisualStudioBootstrapperUrl = 'https://download.visualstudio.microsoft.com/download/pr/c4c405a4-3a8f-4448-9543-4bd65c213937/6ba856e30a7b2cbb42c034ff9b93fe0424855d05cc217556c54d7f9f5b8f7007/vs_Enterprise.exe'
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
