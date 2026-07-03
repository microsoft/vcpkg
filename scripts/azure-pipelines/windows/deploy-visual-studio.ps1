# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path -LiteralPath "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

# See https://learn.microsoft.com/en-us/visualstudio/releases/2026/release-history
# 18.6.2
$VisualStudioBootstrapperUrl = 'https://download.visualstudio.microsoft.com/download/pr/471ad3d6-cb2b-4d53-8edf-a9eeade096a5/3cfa3f8fc957f406dc35be713959a85c10b23b9ed9a865626550e8cf676d96a8/vs_BuildTools.exe'
$Workloads = @(
  'Microsoft.VisualStudio.Workload.VCTools',
  'Microsoft.VisualStudio.Workload.MSBuildTools',
  'Microsoft.VisualStudio.Component.VC.Tools.x86.x64',
  'Microsoft.VisualStudio.Component.VC.Tools.ARM64',
  'Microsoft.VisualStudio.Component.VC.Tools.ARM64EC',
  'Microsoft.VisualStudio.Component.VC.ASAN',
  'Microsoft.VisualStudio.Component.VC.ATL',
  'Microsoft.VisualStudio.Component.VC.ATLMFC',
  'Microsoft.VisualStudio.Component.VC.ATL.ARM64',
  'Microsoft.VisualStudio.Component.VC.MFC.ARM64',
  'Microsoft.VisualStudio.Component.Windows11SDK.28000',
  'Microsoft.VisualStudio.Component.VC.CLI.Support', # .NET parts are needed for easyhook, openni2
  'Microsoft.VisualStudio.Component.VC.Llvm.Clang',
  'Microsoft.VisualStudio.Component.VC.Llvm.ClangToolset',
  'Microsoft.VisualStudio.Component.VC.CMake.Project'
)

$vsArgs = @('--quiet', '--norestart', '--wait', '--nocache')
foreach ($workload in $Workloads) {
  $vsArgs += '--add'
  $vsArgs += $workload
}

DownloadAndInstall -Url $VisualStudioBootstrapperUrl -Args $vsArgs
