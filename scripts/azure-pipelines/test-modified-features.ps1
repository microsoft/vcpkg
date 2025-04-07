# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#

<#
.SYNOPSIS
Runs the 'Test Modified Ports' part of the vcpkg CI system for all platforms.

.PARAMETER Triplet
The triplet to test.

.PARAMETER WorkingRoot
The location used as scratch space for 'installed', 'packages', and 'buildtrees' vcpkg directories.

.PARAMETER FailureLogs
The location to write failure logs. Defaults to current directory / failure-logs

.PARAMETER ArchivesRoot
Equivalent to '-BinarySourceStub "files,$ArchivesRoot"'

.PARAMETER BinarySourceStub
The type and parameters of the binary source. Shared across runs of this script. If
this parameter is not set, binary caching will not be used. Example: "files,W:\"
#>

[CmdletBinding(DefaultParameterSetName="ArchivesRoot")]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Triplet,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    $WorkingRoot,
    [ValidateNotNullOrEmpty()]
    $FailureLogs = './failure-logs',
    [Parameter(ParameterSetName='ArchivesRoot')]
    $ArchivesRoot = $null,
    [Parameter(ParameterSetName='BinarySourceStub')]
    $BinarySourceStub = $null
)

if (-Not ((Test-Path "triplets/$Triplet.cmake") -or (Test-Path "triplets/community/$Triplet.cmake"))) {
    Write-Error "Incorrect triplet '$Triplet', please supply a valid triplet."
    exit 1
}

if ((-Not [string]::IsNullOrWhiteSpace($ArchivesRoot))) {
    if ((-Not [string]::IsNullOrWhiteSpace($BinarySourceStub))) {
        Write-Error "Only one binary caching setting may be used."
        exit 1
    }

    $BinarySourceStub = "files,$ArchivesRoot"
}

$buildtreesRoot = Join-Path $WorkingRoot 'b'
$installRoot = Join-Path $WorkingRoot 'installed'
$packagesRoot = Join-Path $WorkingRoot 'p'

$commonArgs = @(
    "--x-buildtrees-root=$buildtreesRoot",
    "--x-install-root=$installRoot",
    "--x-packages-root=$packagesRoot",
    "--overlay-ports=scripts/test_ports"
)

$cachingArgs = @()
if ([string]::IsNullOrWhiteSpace($BinarySourceStub)) {
    $cachingArgs = @('--no-binarycaching')
} else {
    $cachingArgs += "--binarysource=clear;$BinarySourceStub,readwrite"
}

if ($IsWindows) {
    $vcpkgExe = './vcpkg.exe'
} else {
    $vcpkgExe = './vcpkg'
}

$ciBaselineFile = "$PSScriptRoot/../ci.feature.baseline.txt"
$ciBaselineArg = "--ci-feature-baseline=$ciBaselineFile"

if ($Triplet -eq 'x64-windows-release') {
    $tripletArg = "--host-triplet=$Triplet"
} else {
    $tripletArg = "--triplet=$Triplet"
}

& $vcpkgExe x-test-features --for-merge-with origin/master $tripletArg "--failure-logs=$FailureLogs" $ciBaselineArg @commonArgs @cachingArgs
$lastLastExitCode = $LASTEXITCODE
if ($lastLastExitCode -ne 0)
{
    Write-Error "vcpkg feature testing failed; this is usually a bug in a port. Check for failure logs attached to the run in Azure Pipelines."
}

exit $lastLastExitCode
