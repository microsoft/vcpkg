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
The reason Azure Pipelines is running this script (controls in which mode Binary Caching is used).
If BinarySourceStub is not set, this parameter has no effect. If BinarySourceStub is set and this is
not, binary caching will default to read-write mode.

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
    [String[]]$AdditionalSkips = @(),
    [String[]]$OnlyTest = $null,
    [switch]$PassingIsPassing = $false
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

$skipFailures = $false
if ([string]::IsNullOrWhiteSpace($BinarySourceStub)) {
    $commonArgs += @('--no-binarycaching')
} else {
    $commonArgs += @('--binarycaching')
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

    $commonArgs += @("--binarysource=clear;$BinarySourceStub,$binaryCachingMode")
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
if ($LASTEXITCODE -ne 0)
{
    throw "vcpkg clean failed"
}

$skipList = . "$PSScriptRoot/generate-skip-list.ps1" `
    -Triplet $Triplet `
    -BaselineFile "$PSScriptRoot/../ci.baseline.txt" `
    -SkipFailures:$skipFailures `
    -AdditionalSkips $AdditionalSkips

if ($null -ne $OnlyTest)
{
    $OnlyTest | % {
        $portName = $_
        & "./vcpkg$executableExtension" install --triplet $Triplet @commonArgs $portName
        if (-not $?)
        {
            [System.Console]::Error.WriteLine( `
                "REGRESSION: ${portName}:$triplet. If expected, remove ${portName} from the OnlyTest list." `
            )
        }
    }

    $failureLogsEmpty = ((Test-Path $failureLogs) -and (Get-ChildItem $failureLogs).count -eq 0)
    Write-Host "##vso[task.setvariable variable=FAILURE_LOGS_EMPTY]$failureLogsEmpty"
}
else
{
    if ($Triplet -in @('x64-windows', 'x64-osx', 'x64-linux'))
    {
        # WORKAROUND: These triplets are native-targetting which triggers an issue in how vcpkg handles the skip list.
        # The workaround is to pass the skip list as host-excludes as well.
        & "./vcpkg$executableExtension" ci $Triplet --x-xunit=$xmlFile --exclude=$skipList --host-exclude=$skipList --failure-logs=$failureLogs @commonArgs
    }
    else
    {
        & "./vcpkg$executableExtension" ci $Triplet --x-xunit=$xmlFile --exclude=$skipList --failure-logs=$failureLogs @commonArgs
    }

    $failureLogsEmpty = ((Test-Path $failureLogs) -and (Get-ChildItem $failureLogs).count -eq 0)
    Write-Host "##vso[task.setvariable variable=FAILURE_LOGS_EMPTY]$failureLogsEmpty"

    if ($LASTEXITCODE -ne 0)
    {
        throw "vcpkg ci failed"
    }

    & "$PSScriptRoot/analyze-test-results.ps1" -logDir $xmlResults `
        -triplet $Triplet `
        -baselineFile .\scripts\ci.baseline.txt `
        -passingIsPassing:$PassingIsPassing
}
