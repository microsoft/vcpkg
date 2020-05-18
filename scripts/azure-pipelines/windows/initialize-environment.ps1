# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#
<#
.SYNOPSIS
Sets up the environment to run other vcpkg CI steps in an Azure Pipelines job.

.DESCRIPTION
This script maps network drives from infrastructure and cleans out anything that
might have been leftover from a previous run.

.PARAMETER ForceAllPortsToRebuildKey
A subdirectory / key to use to force a build without any previous run caching,
if necessary.
#>

[CmdletBinding()]
Param(
    [string]$ForceAllPortsToRebuildKey = ''
)

$StorageAccountName = $env:StorageAccountName
$StorageAccountKey = $env:StorageAccountKey

function Remove-DirectorySymlink {
    Param([string]$Path)
    if (Test-Path $Path) {
        [System.IO.Directory]::Delete((Convert-Path $Path), $true)
    }
}

New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name AllowDevelopmentWithoutDevLicense -Value 1 -PropertyType DWORD -Force
 
# Disable UAC
Write-Host "Disabling UAC"
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "0" -Force
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value "0" -Force
Write-Host "User Access Control (UAC) has been disabled." -ForegroundColor Green

# Set PowerShell execution policy to unrestricted
Write-Host "Changing PS execution policy to Unrestricted"
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -ErrorAction Ignore -Scope Process
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -ErrorAction Ignore
Write-Host "PS policy updated"

#Write-Host "Disable UAC"
#Disable-UserAccessControl

Write-Host "Enable long path behavior"
# See https://docs.microsoft.com/en-us/windows/desktop/fileio/naming-a-file#maximum-path-length-limitation
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value  "1" -Force

# fsutil behavior set SymlinkEvaluation [L2L:{0|1}] | [L2R:{0|1}] | [R2R:{0|1}] | [R2L:{0|1}]
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "SymlinkLocalToLocalEvaluation" -Value "1" -Force
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "SymlinkLocalToRemoteEvaluation" -Value "1" -Force
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "SymlinkRemoteToLocalEvaluation" -Value "1" -Force
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "SymlinkRemoteToRemoteEvaluation" -Value "1" -Force

[Environment]::SetEnvironmentVariable("MSYS", "winsymlinks:nativestrict", "Machine")
[Environment]::SetEnvironmentVariable("MSYS2_PATH_TYPE", "inherit", "Machine")

Write-Host 'Setting up archives mount'
if (-Not (Test-Path W:)) {
    net use W: "\\$StorageAccountName.file.core.windows.net\archives" /u:"AZURE\$StorageAccountName" $StorageAccountKey
}

Write-Host 'Creating downloads directory'
mkdir D:\downloads -ErrorAction SilentlyContinue

# Delete entries in the downloads folder, except:
#   those in the 'tools' folder
#   those last accessed in the last 30 days
Get-ChildItem -Path D:\downloads -Exclude "tools" `
    | Where-Object{ $_.LastAccessTime -lt (get-Date).AddDays(-30) } `
    | ForEach-Object{Remove-Item -Path $_ -Recurse -Force}

# Msys sometimes leaves a database lock file laying around, especially if there was a failed job
# which causes unrelated failures in jobs that run later on the machine.
# work around this by just removing the vcpkg installed msys2 if it exists
if( Test-Path D:\downloads\tools\msys2 )
{
    Write-Host "removing previously installed msys2"
    Remove-Item D:\downloads\tools\msys2 -Recurse -Force
}

Write-Host 'Setting up archives path...'
if ([string]::IsNullOrWhiteSpace($ForceAllPortsToRebuildKey))
{
    $archivesPath = 'W:\'
}
else
{
    $archivesPath = "W:\force\$ForceAllPortsToRebuildKey"
    if (-Not (Test-Path $fullPath)) {
        Write-Host 'Creating $archivesPath'
        mkdir $archivesPath
    }
}

Write-Host "Linking archives => $archivesPath"
Remove-DirectorySymlink archives
cmd /c "mklink /D archives $archivesPath"

Write-Host 'Linking installed => E:\installed'
Remove-DirectorySymlink installed
Remove-Item E:\installed -Recurse -Force -ErrorAction SilentlyContinue
mkdir E:\installed
cmd /c "mklink /D installed E:\installed"

Write-Host 'Linking downloads => D:\downloads'
Remove-DirectorySymlink downloads
cmd /c "mklink /D downloads D:\downloads"

Get-Acl "D:\\downloads" |Format-List | Out-Host
"`n"

& C:\Windows\System32\icacls.exe D:\\downloads /grant SD="D:P(A;;GA;;;WD)" /T

$proc = Start-Process -FilePath C:\Windows\System32\icacls.exe D:\\downloads /grant *S-1-5-83-0:"(OI)(CI)F" /T -Wait -PassThru

Write-Host 'Cleaning buildtrees'
Remove-Item buildtrees\* -Recurse -Force -errorAction silentlycontinue

Write-Host 'Cleaning packages'
Remove-Item packages\* -Recurse -Force -errorAction silentlycontinue
