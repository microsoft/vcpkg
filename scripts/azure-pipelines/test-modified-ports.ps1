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

.PARAMETER PassingIsPassing
Indicates that 'Passing, remove from fail list' results should not be emitted as failures. (For example, this is used
when using vcpkg to test a prerelease MSVC++ compiler)
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
    [switch]$PassingIsPassing = $false,
    [switch]$IsLinuxHost = $false
)

if (-Not ((Test-Path "triplets/$Triplet.cmake") -or (Test-Path "triplets/community/$Triplet.cmake"))) {
    Write-Error "Incorrect triplet '$Triplet', please supply a valid triplet."
    throw
}

if ((-Not [string]::IsNullOrWhiteSpace($ArchivesRoot))) {
    if ((-Not [string]::IsNullOrWhiteSpace($BinarySourceStub))) {
        Write-Error "Only one binary caching setting may be used."
        throw
    }

    $BinarySourceStub = "files,$ArchivesRoot"
}

$env:VCPKG_DOWNLOADS = Join-Path $WorkingRoot 'downloads'
$buildtreesRoot = Join-Path $WorkingRoot 'buildtrees'
$installRoot = Join-Path $WorkingRoot 'installed'
$packagesRoot = Join-Path $WorkingRoot 'packages'

$commonArgs = @(
    "--x-buildtrees-root=$buildtreesRoot",
    "--x-install-root=$installRoot",
    "--x-packages-root=$packagesRoot",
    "--overlay-ports=scripts/test_ports"
)
$cachingArgs = @()

$skipFailuresArg = @()
if ([string]::IsNullOrWhiteSpace($BinarySourceStub)) {
    $cachingArgs = @('--no-binarycaching')
} else {
    $cachingArgs = @('--binarycaching')
    $binaryCachingMode = 'readwrite'
    if ([string]::IsNullOrWhiteSpace($BuildReason)) {
        Write-Host 'Build reason not specified, defaulting to using binary caching in read write mode.'
    }
    elseif ($BuildReason -eq 'PullRequest') {
        Write-Host 'Build reason was Pull Request, using binary caching in read write mode, skipping failures.'
        $skipFailuresArg = @('--skip-failures')
    }
    else {
        Write-Host "Build reason was $BuildReason, using binary caching in write only mode."
        $binaryCachingMode = 'write'
    }

    $cachingArgs += @("--binarysource=clear;$BinarySourceStub,$binaryCachingMode")
}

if ($IsLinuxHost) {
    $env:HOME = '/home/agent'
    $executableExtension = [string]::Empty
}
elseif ($Triplet -eq 'x64-osx') {
    $executableExtension = [string]::Empty
}
else {
    $executableExtension = '.exe'
}

$failureLogs = Join-Path $ArtifactStagingDirectory 'failure-logs'
$xunitFile = Join-Path $ArtifactStagingDirectory "$Triplet-results.xml"

if ($IsWindows)
{
    mkdir empty
    cmd /c "robocopy.exe empty `"$buildtreesRoot`" /MIR /NFL /NDL /NC /NP > nul"
    cmd /c "robocopy.exe empty `"$packagesRoot`" /MIR /NFL /NDL /NC /NP > nul"
    cmd /c "robocopy.exe empty `"$installRoot`" /MIR /NFL /NDL /NC /NP > nul"
    rmdir empty
}

& "./vcpkg$executableExtension" x-ci-clean @commonArgs
if ($LASTEXITCODE -ne 0)
{
    throw "vcpkg clean failed"
}

$parentHashes = @()
if (($BuildReason -eq 'PullRequest') -and -not $NoParentHashes)
{
    $headBaseline = Get-Content "$PSScriptRoot/../ci.baseline.txt" -Raw

    # Prefetch tools for better output
    foreach ($tool in @('cmake', 'ninja', 'git')) {
        & "./vcpkg$executableExtension" fetch $tool
        if ($LASTEXITCODE -ne 0)
        {
            throw "Failed to fetch $tool"
        }
    }

    Write-Host "Comparing with HEAD~1"
    & git revert -n -m 1 HEAD | Out-Null
    $parentBaseline = Get-Content "$PSScriptRoot/../ci.baseline.txt" -Raw
    if ($parentBaseline -eq $headBaseline)
    {
        Write-Host "CI baseline unchanged, determining parent hashes"
        $parentHashesFile = Join-Path $ArtifactStagingDirectory 'parent-hashes.json'
        $parentHashes = @("--parent-hashes=$parentHashesFile")
        # The vcpkg.cmake toolchain file is not part of ABI hashing,
        # but changes must trigger at least some testing.
        Copy-Item "scripts/buildsystems/vcpkg.cmake" -Destination "scripts/test_ports/cmake"
        Copy-Item "scripts/buildsystems/vcpkg.cmake" -Destination "scripts/test_ports/cmake-user"
        & "./vcpkg$executableExtension" ci "--triplet=$Triplet" --dry-run "--ci-baseline=$PSScriptRoot/../ci.baseline.txt" @commonArgs --no-binarycaching "--output-hashes=$parentHashesFile"
    }
    else
    {
        Write-Host "CI baseline was modified, not using parent hashes"
    }
    Write-Host "Running CI for HEAD"
    & git reset --hard HEAD
}

# The vcpkg.cmake toolchain file is not part of ABI hashing,
# but changes must trigger at least some testing.
Copy-Item "scripts/buildsystems/vcpkg.cmake" -Destination "scripts/test_ports/cmake"
Copy-Item "scripts/buildsystems/vcpkg.cmake" -Destination "scripts/test_ports/cmake-user"
& "./vcpkg$executableExtension" ci "--triplet=$Triplet" --failure-logs=$failureLogs --x-xunit=$xunitFile "--ci-baseline=$PSScriptRoot/../ci.baseline.txt" @commonArgs @cachingArgs @parentHashes @skipFailuresArg

$failureLogsEmpty = (-Not (Test-Path $failureLogs) -Or ((Get-ChildItem $failureLogs).count -eq 0))
Write-Host "##vso[task.setvariable variable=FAILURE_LOGS_EMPTY]$failureLogsEmpty"

if ($LASTEXITCODE -ne 0)
{
    throw "vcpkg ci failed"
}

Write-Host "##vso[task.setvariable variable=XML_RESULTS_FILE]$xunitFile"
