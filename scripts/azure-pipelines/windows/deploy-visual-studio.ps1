# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

if (Test-Path -LiteralPath "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

# See https://learn.microsoft.com/en-us/visualstudio/releases/2026/release-history
# 18.11.0
$VisualStudioBootstrapperUrl = 'https://download.visualstudio.microsoft.com/download/pr/4ee8a2e7-bc71-435a-8180-6703ab4d2017/89341fb2edf12ef29977078fdc72a9e47767ce6895cc297f274bc4a379db4c71/vs_BuildTools.exe'
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
