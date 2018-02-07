[CmdletBinding()]
param(
    [string]$Triplet
)

function IsReparsePoint([string]$path) {
  $file = Get-Item $path -Force -ea SilentlyContinue
  return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

$ErrorActionPreference = "Stop"

$scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"

$vcpkgRootDir = vcpkgFindFileRecursivelyUp $scriptsDir .vcpkg-root

vcpkgRemoveItem "$vcpkgRootDir\TEST-full-ci.xml"

& "$vcpkgRootDir\bootstrap-vcpkg.bat"
if (-not $?) { exit $? }

$driveLetter = "I:"
Write-Host "Deleting drive $driveLetter\ ..."
net use $driveLetter /delete
Write-Host "Deleting drive $driveLetter\ ... done."

$remoteShare = "\\vcpkg-000\installed"
Write-Host "Mapping drive $driveLetter\ to $remoteShare ..."
net use $driveLetter $remoteShare B7PeL56r /USER:\vcpkg
Write-Host "Mapping drive $driveLetter\ to $remoteShare ... done."

$installedDirLocal = "$vcpkgRootDir\installed"
$installedDirRemote = "$driveLetter\vcpkg-full-ci-$Triplet"

Write-Host "Unlinking/deleting $installedDirLocal ..."
if (IsReparsePoint $installedDirLocal)
{
    cmd /c rmdir $installedDirLocal
}
else
{
    vcpkgRemoveItem $installedDirLocal
}
Write-Host "Unlinking/deleting $installedDirLocal ... done."

Write-Host "Creating $installedDirRemote ..."
vcpkgCreateDirectoryIfNotExists $installedDirRemote
Write-Host "Creating $installedDirRemote ... done."

Write-Host "Linking $installedDirLocal to $installedDirRemote ..."
cmd /c mklink /D $installedDirLocal $installedDirRemote
Write-Host "Linking $installedDirLocal to $installedDirRemote ... done."

$packagesDir = "$vcpkgRootDir\packages"
Write-Host "Deleting $packagesDir ..."
vcpkgRemoveItem "$packagesDir"
Write-Host "Deleting $packagesDir ... done."

# ./vcpkg remove --outdated --recurse

# ./vcpkg ci $Triplet --x-xunit=TEST-full-ci.xml --exclude=libsodium,aws-sdk-cpp
