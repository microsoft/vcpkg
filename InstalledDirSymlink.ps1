[CmdletBinding()]
param(
    [string]$Triplet
)

$scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"
. "$scriptsDir\VcpkgPowershellUtils-Private.ps1"

$vcpkgRootDir = vcpkgFindFileRecursivelyUp $scriptsDir .vcpkg-root

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

unlinkOrDeleteDirectory $installedDirLocal

Write-Host "Creating $installedDirRemote ..."
vcpkgCreateDirectoryIfNotExists $installedDirRemote
Write-Host "Creating $installedDirRemote ... done."

Write-Host "Linking $installedDirLocal to $installedDirRemote ..."
cmd /c mklink /D $installedDirLocal $installedDirRemote
Write-Host "Linking $installedDirLocal to $installedDirRemote ... done."