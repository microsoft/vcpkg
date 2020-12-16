#!pwsh
#Requires -Version 6.0

<#
.SYNOPSIS
Installs the base box at the specified version from the share.

.PARAMETER FileshareMachine
The machine which is acting as a fileshare

.PARAMETER BoxVersion
The version of the box to add. Defaults to latest if nothing is passed.
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [String]$FileshareMachine,

    [Parameter()]
    [String]$BoxVersion
)

Set-StrictMode -Version 2

if (-not $IsMacOS) {
    throw 'This script should only be run on a macOS host'
}

$mountPoint = '/Users/vcpkg/vagrant/share'

if (mount | grep "on $mountPoint (") {
    umount $mountPoint
    if (-not $?) {
        Write-Error "umount $mountPoint failed with return code $LASTEXITCODE."
        throw
    }
}

sshfs "fileshare@${FileshareMachine}:/Users/fileshare/share" $mountPoint
if ($LASTEXITCODE -eq 1) {
    Write-Error 'sshfs returned 1.
This means that the osxfuse kernel extension was not allowed to load.
Please open System Preferences > Security & Privacy > General,
and allow the kernel extension to load.
Then, rerun this script.

If you''ve already done this, you probably need to add your ssh keys to the fileshare machine.'
    throw
} elseif (-not $?) {
    Write-Error "sshfs failed with return code $LASTEXITCODE."
    throw
}

if (-not [String]::IsNullOrEmpty($BoxVersion)) {
    $versionArgs = @("--box-version", $BoxVersion)
} else {
    $versionArgs = @()
}

vagrant box add "$mountPoint/vcpkg-boxes/macos-ci.json" @versionArgs

