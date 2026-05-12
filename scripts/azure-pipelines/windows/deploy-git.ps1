# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

param([string]$SasToken)

if (Test-Path -LiteralPath "$PSScriptRoot/utility-prefix.ps1") {
  . "$PSScriptRoot/utility-prefix.ps1"
}

$GitUrl = Get-AssetUrl `
  -SasToken $SasToken `
  -InternetUrl 'https://github.com/git-for-windows/git/releases/download/v2.54.0.windows.1/Git-2.54.0-64-bit.exe' `
  -BlobAssetName 'Git-2.54.0-64-bit.exe'

$GitInfContent = @"
[Setup]
Lang=default
Dir=C:\Program Files\Git
Group=Git
NoIcons=0
SetupType=default
Components=gitlfs,assoc,assoc_sh,scalar
Tasks=
EditorOption=VIM
CustomEditorPath=
DefaultBranchOption=
PathOption=Cmd
SSHOption=OpenSSH
TortoiseOption=false
CURLOption=WinSSL
CRLFOption=CRLFCommitAsIs
BashTerminalOption=ConHost
GitPullBehaviorOption=FFOnly
UseCredentialManager=Enabled
PerformanceTweaksFSCache=Enabled
EnableSymlinks=Disabled
EnableFSMonitor=Disabled
"@

try {
  $installer = Get-LocalOrDownloadedFile -Url $GitUrl
  $gitInfPath = Join-Path (Split-Path -Parent $installer.Path) 'git.inf'
  Set-Content -LiteralPath $gitInfPath -Value $gitInfContent -Encoding ascii

  Write-Host 'Installing Git for Windows...'
  $proc = Start-Process -FilePath $installer.Path -ArgumentList @(
    '/VERYSILENT',
    '/NORESTART',
    '/NOCANCEL',
    '/SP-',
    '/SUPPRESSMSGBOXES',
    "/LOADINF=`"$gitInfPath`""
  ) -Wait -PassThru
  $exitCode = $proc.ExitCode

  if ($exitCode -eq 0) {
    Write-Host 'Installation successful!'
  } else {
    Write-Error "Installation failed! Exited with $exitCode."
  }
} catch {
  Write-Error "Installation failed! Exception: $($_.Exception.Message)"
} finally {
  if ($null -ne $gitInfPath) {
    Remove-Item -LiteralPath $gitInfPath -Force -ErrorAction SilentlyContinue
  }

  if ($null -ne $installer -and $installer.Temporary) {
    Remove-Item -LiteralPath $installer.Path -Force
  }
}
