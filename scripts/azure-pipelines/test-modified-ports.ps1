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

.PARAMETER ArtifactStagingDirectory
The Azure Pipelines artifacts directory. If not supplied, defaults to the current directory.

.PARAMETER ArchivesRoot
The location where the binary caching archives are stored. Shared across runs of this script. If
this parameter is not set, binary caching will not be used.

.PARAMETER BuildReason
The reason Azure Pipelines is running this script (controls in which mode Binary Caching is used).
If ArchivesRoot is not set, this parameter has no effect. If ArchivesRoot is set and this is not,
binary caching will default to read-write mode.
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Triplet,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    $WorkingRoot,
    [ValidateNotNullOrEmpty()]
    $ArtifactStagingDirectory = '.',
    $ArchivesRoot = $null,
    $BuildReason = $null
)

if (-Not (Test-Path "triplets/$Triplet.cmake")) {
    Write-Error "Incorrect triplet '$Triplet', please supply a valid triplet."
    throw
}

$env:VCPKG_DOWNLOADS = Join-Path $WorkingRoot 'downloads'
$buildtreesRoot = Join-Path $WorkingRoot 'buildtrees'
$installRoot = Join-Path $WorkingRoot 'installed'
$packagesRoot = Join-Path $WorkingRoot 'packages'

$usingBinaryCaching = -Not ([string]::IsNullOrWhiteSpace($ArchivesRoot))
$commonArgs = @()
if ($usingBinaryCaching) {
    $commonArgs += @('--binarycaching')
} else {
    $commonArgs += @('--no-binarycaching')
}

$commonArgs += @(
    "--x-buildtrees-root=$buildtreesRoot",
    "--x-install-root=$installRoot",
    "--x-packages-root=$packagesRoot",
    "--overlay-ports=scripts/test_ports"
)

$skipFailures = $false
if ($usingBinaryCaching) {
    $binaryCachingMode = 'readwrite'
    if ([string]::IsNullOrWhiteSpace($BuildReason)) {
        Write-Host 'Build reason not specified, defaulting to using binary caching in read write mode.'
    }
    elseif ($BuildReason -eq 'PullRequest') {
        Write-Host 'Build reason was Pull Request, using binary caching in read write mode, skipping failures.'
        $skipFailures = $true
    }
    else {
        Write-Host "Build reason was $BuildReason, using binary caching in write only mode."
        $binaryCachingMode = 'write'
    }

    $commonArgs += @("--x-binarysource=clear;files,$ArchivesRoot,$binaryCachingMode")
}

if ($Triplet -eq 'x64-linux') {
    $env:HOME = '/home/agent'
    $executableExtension = [string]::Empty
}
elseif ($Triplet -eq 'x64-osx') {
    $executableExtension = [string]::Empty
}
else {
    $executableExtension = '.exe'
}

$xmlResults = Join-Path $ArtifactStagingDirectory 'xml-results'
mkdir $xmlResults
$xmlFile = Join-Path $xmlResults "$Triplet.xml"

$failureLogs = Join-Path $ArtifactStagingDirectory 'failure-logs'

& "./vcpkg$executableExtension" x-ci-clean @commonArgs
$skipList = . "$PSScriptRoot/generate-skip-list.ps1" `
    -Triplet $Triplet `
    -BaselineFile "$PSScriptRoot/../ci.baseline.txt" `
    -SkipFailures:$skipFailures

# WORKAROUND: the x86-windows flavors of these are needed for all cross-compilation, but they are not auto-installed.
# Install them so the CI succeeds:
if ($Triplet -in @('x64-uwp', 'arm64-windows', 'arm-uwp')) {
    .\vcpkg.exe install protobuf:x86-windows boost-build:x86-windows sqlite3:x86-windows @commonArgs
}

& "./vcpkg$executableExtension" ci $Triplet --x-xunit=$xmlFile --exclude=$skipList --failure-logs=$failureLogs @commonArgs
& "$PSScriptRoot/analyze-test-results.ps1" -logDir $xmlResults `
    -triplet $Triplet `
    -baselineFile .\scripts\ci.baseline.txt
