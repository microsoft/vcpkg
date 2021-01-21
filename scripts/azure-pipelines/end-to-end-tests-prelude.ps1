$TestingRoot = Join-Path $WorkingRoot 'testing'
$buildtreesRoot = Join-Path $TestingRoot 'buildtrees'
$installRoot = Join-Path $TestingRoot 'installed'
$packagesRoot = Join-Path $TestingRoot 'packages'
$NuGetRoot = Join-Path $TestingRoot 'nuget'
$NuGetRoot2 = Join-Path $TestingRoot 'nuget2'
$ArchiveRoot = Join-Path $TestingRoot 'archives'
$VersionFilesRoot = Join-Path $TestingRoot 'version-test'
$commonArgs = @(
    "--triplet",
    $Triplet,
    "--x-buildtrees-root=$buildtreesRoot",
    "--x-install-root=$installRoot",
    "--x-packages-root=$packagesRoot",
    "--overlay-ports=$PSScriptRoot/../e2e_ports/overlays"
)
$Script:CurrentTest = 'unassigned'

if ($IsWindows)
{
    $VcpkgExe = Get-Item './vcpkg.exe'
}
else
{
    $VcpkgExe = Get-Item './vcpkg'
}

function Refresh-TestRoot {
    Remove-Item -Recurse -Force $TestingRoot -ErrorAction SilentlyContinue
    mkdir $TestingRoot | Out-Null
    mkdir $NuGetRoot | Out-Null
}

function Require-FileExists {
    [CmdletBinding()]
    Param(
        [string]$File
    )
    if (-Not (Test-Path $File)) {
        throw "'$Script:CurrentTest' failed to create file '$File'"
    }
}

function Require-FileNotExists {
    [CmdletBinding()]
    Param(
        [string]$File
    )
    if (Test-Path $File) {
        throw "'$Script:CurrentTest' should not have created file '$File'"
    }
}

function Throw-IfFailed {
    if ($LASTEXITCODE -ne 0) {
        throw "'$Script:CurrentTest' had a step with a nonzero exit code"
    }
}

function Throw-IfNotFailed {
    if ($LASTEXITCODE -eq 0) {
        throw "'$Script:CurrentTest' had a step with an unexpectedly zero exit code"
    }
}

function Write-Trace ([string]$text) {
    Write-Host (@($MyInvocation.ScriptName, ":", $MyInvocation.ScriptLineNumber, ": ", $text) -join "")
}

function Run-Vcpkg {
    Param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$TestArgs
    )
    $Script:CurrentTest = "vcpkg $($testArgs -join ' ')"
    Write-Host $Script:CurrentTest
    & $VcpkgExe @testArgs
}

Refresh-TestRoot
