[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$Triplet,
    [Parameter(Mandatory=$true)][bool]$incremental
)

$scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"
. "$scriptsDir\VcpkgPowershellUtils-Private.ps1"

$vcpkgRootDir = vcpkgFindFileRecursivelyUp $scriptsDir .vcpkg-root

function IsReparsePoint([Parameter(Mandatory=$true)][string]$path)
{
    $file = Get-Item $path -Force -ea SilentlyContinue
    return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

function unlinkOrDeleteDirectory([Parameter(Mandatory=$true)][string]$path)
{
    Write-Host "Unlinking/deleting $path ..."
    if (IsReparsePoint $path)
    {
        Write-Host "Reparse point detected. Unlinking."
        cmd /c rmdir $path
    }
    else
    {
        Write-Host "Non-reparse point detected. Deleting."
        vcpkgRemoveItem $path
    }
    Write-Host "Unlinking/deleting $path ... done."
}

$driveLetter = "I:"
Write-Host "Deleting drive $driveLetter\ ..."
if (Test-Path $driveLetter)
{
    net use $driveLetter /delete
}
Write-Host "Deleting drive $driveLetter\ ... done."

$remoteShare = "\\vcpkg-000\installed"
Write-Host "Mapping drive $driveLetter\ to $remoteShare ..."
net use $driveLetter $remoteShare B7PeL56r /USER:\vcpkg
Write-Host "Mapping drive $driveLetter\ to $remoteShare ... done."

$installedDirLocal = "$vcpkgRootDir\installed"
$installedDirRemote = "$driveLetter\vcpkg-full-ci-$Triplet"
vcpkgCreateDirectoryIfNotExists $installedDirRemote

unlinkOrDeleteDirectory $installedDirLocal

if ($incremental)
{
    Write-Host "Linking $installedDirLocal to $installedDirRemote ..."
    cmd /c mklink /D $installedDirLocal $installedDirRemote
    Write-Host "Linking $installedDirLocal to $installedDirRemote ... done."
}
else
{
    Write-Host "Creating $installedDirRemote ..."
    vcpkgCreateDirectoryIfNotExists $installedDirRemote
    Write-Host "Creating $installedDirRemote ... done."
}

unlinkOrDeleteDirectory "$vcpkgRootDir\archives"
cmd /c mklink /D "$vcpkgRootDir\archives" "$driveLetter\archives"
