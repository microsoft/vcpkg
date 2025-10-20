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
Equivalent to '-BinarySourceStub "files,$ArchivesRoot"'

.PARAMETER BinarySourceStub
The type and parameters of the binary source. Shared across runs of this script. If
this parameter is not set, binary caching will not be used. Example: "files,W:\"

.PARAMETER BuildReason
The reason Azure Pipelines is running this script. For invocations caused by `PullRequest`,
modified ports are identified by changed hashes with regard to git HEAD~1 (subject to NoParentHashes),
and ports marked as failing in the CI baseline (or which depend on such ports) are skipped.
If BinarySourceStub is set and this parameter is set to a non-empty value other than `PullRequest`,
binary caching will be in write-only mode.

.PARAMETER NoParentHashes
Indicates to not use parent hashes even for pull requests.

.PARAMETER AllowUnexpectedPassing
Indicates that 'Passing, remove from fail list' results should not be emitted as failures. (For example, this is used
when using vcpkg to test a prerelease MSVC++ compiler)

.Parameter KnownFailuresAbiLog
If present, the path to a file containing a list of known ABI failing ABI hashes, typically generated
by the `vcpkg x-check-features` command.
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
    $ArtifactStagingDirectory = '.',
    [Parameter(ParameterSetName='ArchivesRoot')]
    $ArchivesRoot = $null,
    [Parameter(ParameterSetName='BinarySourceStub')]
    $BinarySourceStub = $null,
    [String]$BuildReason = $null,
    [switch]$NoParentHashes = $false,
    [switch]$AllowUnexpectedPassing = $false
)

function Add-ToolchainToTestCMake {
    # The vcpkg.cmake toolchain file is not part of ABI hashing,
    # but changes must trigger at least some testing.
    Copy-Item "scripts/buildsystems/vcpkg.cmake" -Destination "scripts/test_ports/cmake"
    Copy-Item "scripts/buildsystems/vcpkg.cmake" -Destination "scripts/test_ports/cmake-user"
}

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

$env:AZCOPY_LOG_LOCATION = Join-Path $WorkingRoot 'azcopy-logs'
$env:AZCOPY_JOB_PLAN_LOCATION = Join-Path $WorkingRoot 'azcopy-plans'
if ($Triplet -eq 'x64-osx') {
    $env:AZCOPY_BUFFER_GB = 2
    $env:AZCOPY_CONCURRENCY_VALUE = 8
}
if (!(Test-Path $env:AZCOPY_LOG_LOCATION))
{
    New-Item -ItemType Directory -Path $env:AZCOPY_LOG_LOCATION | Out-Null
}
Write-Host "AzCopy logs location: $env:AZCOPY_LOG_LOCATION"
Write-Host "##vso[task.setvariable variable=AZCOPY_LOGS_EMPTY]$true"

$commonArgs = @(
    "--x-buildtrees-root=$buildtreesRoot",
    "--x-install-root=$installRoot",
    "--x-packages-root=$packagesRoot",
    "--overlay-ports=scripts/test_ports"
)

$testFeatures = $false
$cachingArgs = @()
$skipFailuresArgs = @()
if ([string]::IsNullOrWhiteSpace($BinarySourceStub)) {
    $cachingArgs = @('--binarysource', 'clear')
} else {
    $cachingArgs = @()
    $binaryCachingMode = 'readwrite'
    if ([string]::IsNullOrWhiteSpace($BuildReason)) {
        Write-Host 'Build reason not specified, defaulting to using binary caching in read write mode.'
    }
    elseif ($BuildReason -eq 'PullRequest') {
        Write-Host 'Build reason was Pull Request, using binary caching in read write mode, testing features, skipping failures.'
        $skipFailuresArgs = @('--skip-failures')
        $testFeatures = $true
    }
    else {
        Write-Host "Build reason was $BuildReason, using binary caching in write only mode."
        $binaryCachingMode = 'write'
    }

    $cachingArgs += "--binarysource=clear;$BinarySourceStub,$binaryCachingMode"
}

if ($IsWindows) {
    $vcpkgExe = './vcpkg.exe'
} else {
    $vcpkgExe = './vcpkg'
}

if ($Triplet -eq 'x64-windows-release') {
    $tripletArg = "--host-triplet=$Triplet"
} else {
    $tripletArg = "--triplet=$Triplet"
}

$failureLogs = Join-Path $ArtifactStagingDirectory 'failure-logs'
$failureLogsArg = "--failure-logs=$failureLogs"
$knownFailuresFromArgs = @()
if ($testFeatures) {
    & $vcpkgExe x-ci-clean @commonArgs
    $lastLastExitCode = $LASTEXITCODE
    if ($lastLastExitCode -ne 0)
    {
        Write-Error "vcpkg x-ci-clean failed. This is usually an infrastructure problem; trying again may help."
        exit $lastLastExitCode
    }

    $ciFeatureBaselineFile = "$PSScriptRoot/../ci.feature.baseline.txt"
    $ciFeatureBaselineArg = "--ci-feature-baseline=$ciFeatureBaselineFile"
    $knownFailingAbisFile = Join-Path $ArtifactStagingDirectory 'failing-abi-log.txt'
    $failingAbiLogArg = "--failing-abi-log=$knownFailingAbisFile"
    & $vcpkgExe x-test-features --for-merge-with origin/master $tripletArg $failureLogsArg $ciBaselineArg $failingAbiLogArg $ciFeatureBaselineArg @commonArgs @cachingArgs
    $lastLastExitCode = $LASTEXITCODE
    $azcopyLogsEmpty = ((Get-ChildItem $env:AZCOPY_LOG_LOCATION).Count -eq 0)
    Write-Host "##vso[task.setvariable variable=AZCOPY_LOGS_EMPTY]$azcopyLogsEmpty"
    if ($lastLastExitCode -ne 0)
    {
        Write-Host "##vso[task.setvariable variable=FAILURE_LOGS_EMPTY]$false"
        Write-Error "vcpkg feature testing failed; this is usually a bug in one of the features in the port(s) edited in this pull request. Check for failure logs attached to the run in Azure Pipelines."
        exit $lastLastExitCode
    }

    $knownFailuresFromArgs += "--known-failures-from=$knownFailingAbisFile"
}

$ciBaselineFile = "$PSScriptRoot/../ci.baseline.txt"
$ciBaselineArg = "--ci-baseline=$ciBaselineFile"
$toolMetadataFile = "$PSScriptRoot/../vcpkg-tool-metadata.txt"

& $vcpkgExe x-ci-clean @commonArgs
$lastLastExitCode = $LASTEXITCODE
if ($lastLastExitCode -ne 0)
{
    Write-Error "vcpkg x-ci-clean failed. This is usually an infrastructure problem; trying again may help."
    exit $lastLastExitCode
}

if ($IsMacOS)
{
    Write-Host "macOS disk space report:"
    & df -h | Where-Object { $_ -match "Avail|/System/Volumes/Data$" }
    & du -sh $WorkingRoot
}

$parentHashesArgs = @()
if (($BuildReason -eq 'PullRequest') -and -not $NoParentHashes)
{
    $headBaseline = Get-Content $ciBaselineFile -Raw
    $headTool = Get-Content $toolMetadataFile  -Raw

    Write-Host "Comparing with HEAD~1"
    & git revert -n -m 1 HEAD | Out-Null
    $lastLastExitCode = $LASTEXITCODE
    if ($lastLastExitCode -ne 0)
    {
        Write-Error "git revert -n -m 1 HEAD failed"
        exit $lastLastExitCode
    }

    $parentBaseline = Get-Content $ciBaselineFile -Raw
    $parentTool = Get-Content $toolMetadataFile  -Raw
    if (($parentBaseline -eq $headBaseline) -and ($parentTool -eq $headTool))
    {
        Write-Host "CI baseline unchanged, determining parent hashes"
        $parentHashesFile = Join-Path $ArtifactStagingDirectory 'parent-hashes.json'
        $parentHashesArgs += "--parent-hashes=$parentHashesFile"
        Add-ToolchainToTestCMake
        & $vcpkgExe ci $tripletArg --dry-run $ciBaselineArg @commonArgs --no-binarycaching "--output-hashes=$parentHashesFile"
        $lastLastExitCode = $LASTEXITCODE
        if ($lastLastExitCode -ne 0)
        {
            Write-Error "Generating parent hashes failed; this is usually an infrastructure problem with vcpkg"
            exit $lastLastExitCode
        }
    }
    else
    {
        Write-Host "Tool or baseline modified, not using parent hashes"
    }

    Write-Host "Running CI for HEAD"
    & git reset --hard HEAD
    $lastLastExitCode = $LASTEXITCODE
    if ($lastLastExitCode -ne 0)
    {
        Write-Error "git reset --hard HEAD failed"
        exit $lastLastExitCode
    }
}

$allowUnexpectedPassingArgs = @()
if ($AllowUnexpectedPassing) {
    $allowUnexpectedPassingArgs = @('--allow-unexpected-passing')
}

Add-ToolchainToTestCMake
$xunitFile = Join-Path $ArtifactStagingDirectory "$Triplet-results.xml"
$xunitArg = "--x-xunit=$xunitFile"
$prHashesFile = Join-Path $ArtifactStagingDirectory "pr-hashes.json"
& $vcpkgExe ci `
    $tripletArg `
    $failureLogsArg `
    "--output-hashes=$prHashesFile" `
    $xunitArg `
    $ciBaselineArg `
    @commonArgs `
    @cachingArgs `
    @parentHashesArgs `
    @skipFailuresArgs `
    @knownFailuresFromArgs `
    @allowUnexpectedPassingArgs
$lastLastExitCode = $LASTEXITCODE
$failureLogsEmpty = (-Not (Test-Path $failureLogs) -Or ((Get-ChildItem $failureLogs).Count -eq 0))
Write-Host "##vso[task.setvariable variable=FAILURE_LOGS_EMPTY]$failureLogsEmpty"
$azcopyLogsEmpty = ((Get-ChildItem $env:AZCOPY_LOG_LOCATION).Count -eq 0)
Write-Host "##vso[task.setvariable variable=AZCOPY_LOGS_EMPTY]$azcopyLogsEmpty"
Write-Host "##vso[task.setvariable variable=XML_RESULTS_FILE]$xunitFile"

if ($lastLastExitCode -ne 0)
{
    Write-Error "vcpkg ci testing failed; this is usually a bug in a port. Check for failure logs attached to the run in Azure Pipelines."
}

exit $lastLastExitCode
