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

.PARAMETER UseEnvironmentSasToken
Equivalent to '-BinarySourceStub "x-azblob,https://$($env:PROVISIONED_AZURE_STORAGE_NAME).blob.core.windows.net/archives,$($env:PROVISIONED_AZURE_STORAGE_SAS_TOKEN)"'

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
    [switch]
    $UseEnvironmentSasToken = $false,
    [Parameter(ParameterSetName='BinarySourceStub')]
    $BinarySourceStub = $null,
    $BuildReason = $null,
    [switch]
    $PassingIsPassing = $false
)

if (-Not ((Test-Path "triplets/$Triplet.cmake") -or (Test-Path "triplets/community/$Triplet.cmake"))) {
    Write-Error "Incorrect triplet '$Triplet', please supply a valid triplet."
    throw
}

$usingBinaryCaching = $true
if ([string]::IsNullOrWhiteSpace($BinarySourceStub)) {
    if ([string]::IsNullOrWhiteSpace($ArchivesRoot)) {
        if ($UseEnvironmentSasToken) {
            $BinarySourceStub = "x-azblob,https://$($env:PROVISIONED_AZURE_STORAGE_NAME).blob.core.windows.net/archives,$($env:PROVISIONED_AZURE_STORAGE_SAS_TOKEN)"
        } else {
            $usingBinaryCaching = $false
        }
    } else {
        if ($UseEnvironmentSasToken) {
            Write-Error "Only one binary caching setting may be used."
            throw
        } else {
            $BinarySourceStub = "files,$ArchivesRoot"
        }
    }
} elseif ((-Not [string]::IsNullOrWhiteSpace($ArchivesRoot)) -Or $UseEnvironmentSasToken) {
    Write-Error "Only one binary caching setting may be used."
    throw
}

$env:VCPKG_DOWNLOADS = Join-Path $WorkingRoot 'downloads'
$buildtreesRoot = Join-Path $WorkingRoot 'buildtrees'
$installRoot = Join-Path $WorkingRoot 'installed'
$packagesRoot = Join-Path $WorkingRoot 'packages'

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
$skipList = . "$PSScriptRoot/generate-skip-list.ps1" `
    -Triplet $Triplet `
    -BaselineFile "$PSScriptRoot/../ci.baseline.txt" `
    -SkipFailures:$skipFailures

$LogSkippedPorts = $true # Maybe parameter
$changedPorts = @()
$skippedPorts = @()
if ($LogSkippedPorts) {
    $diffFile = Join-Path $WorkingRoot 'changed-ports.diff'
    Start-Process -FilePath 'git' -ArgumentList 'diff --name-only HEAD~10 -- versions ports' `
        -NoNewWindow -Wait `
        -RedirectStandardOutput $diffFile
    $changedPorts = (Get-Content -Path $diffFile) `
        -match '^ports/|^versions/.-/' `
        -replace '^(ports/|versions/.-/)([^/]*)(/.*|[.]json$)','$2' `
        | Sort-Object -Unique
    $skippedPorts = $skipList -Split ','
    $changedPorts | ForEach-Object {
        if ($skippedPorts -contains $_) {
            $port = $_
            Write-Host "##vso[task.logissue type=error]Not building changed port '$port`:$Triplet', reason: CI baseline file."
        }
    }
}

$hostArgs = @()
if ($Triplet -in @('x64-windows', 'x64-osx', 'x64-linux'))
{
    # WORKAROUND: These triplets are native-targetting which triggers an issue in how vcpkg handles the skip list.
    # The workaround is to pass the skip list as host-excludes as well.
    $hostArgs = @("--host-exclude=$skipList")
}

$current_port_and_features = ':'
& "./vcpkg$executableExtension" ci $Triplet --x-xunit=$xmlFile --exclude=$skipList --failure-logs=$failureLogs @hostArgs @commonArgs `
    | ForEach-Object {
        $_
        if ($LogSkippedPorts) {
            if ($_ -match '^ *([^ :]+):[^:]*: *cascade:' -and $changedPorts -contains $Matches[1]) {
                $port = $Matches[1]
                Write-Host "##vso[task.logissue type=error]Not building changed port '$port`:$Triplet', reason: cascade from CI baseline file."
            }
            elseif ($_ -match '^Building package ([^ ]+)[.][.][.]') {
                $current_port_and_features = $Matches[1]
            }
            elseif ($_ -match 'failed with: CASCADED_DUE_TO_MISSING_DEPENDENCIES') {
                & "./vcpkg$executableExtension" depend-info $current_port_and_features | ForEach-Object {
                    if ($_ -match '^([^:[]+)[:[]' -and $changedPorts -contains $Matches[1]) {
                        Write-Host "##vso[task.logissue type=error]Not building depending port '$current_port_and_features', reason: cascade due to missing dependencies."
                    }
                }
            }
        }
    }

& "$PSScriptRoot/analyze-test-results.ps1" -logDir $xmlResults `
    -triplet $Triplet `
    -baselineFile .\scripts\ci.baseline.txt `
    -passingIsPassing:$PassingIsPassing
