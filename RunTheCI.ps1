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

net use I: /delete
net use I: \\vcpkg-000\installed B7PeL56r /USER:\vcpkg

$installedDirLocal = "$vcpkgRootDir\installed"
$installedDirRemote = "I:\vcpkg-full-ci-$Triplet"

# Unlink directory if it is a symlink, otherwise delete it
if (IsReparsePoint $installedDirLocal)
{
    cmd /c rmdir $installedDirLocal
}
else
{
    vcpkgRemoveItem $installedDirLocal
}

cmd /c mkdir $installedDirRemote
cmd /c mklink /D $installedDirLocal $installedDirRemote

vcpkgRemoveItem "$vcpkgRootDir\packages"

# ./vcpkg remove --outdated --recurse

# ./vcpkg ci $Triplet --x-xunit=TEST-full-ci.xml --exclude=libsodium,aws-sdk-cpp
