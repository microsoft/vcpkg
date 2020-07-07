#Requires -Version 3.0

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$PortsTree,
    [Parameter()]
    [switch]$IgnoreErrors # allows one to just format
)

# .../vcpkg/scripts/azure-pipelines/windows
# .../vcpkg/scripts/azure-pipelines
# .../vcpkg/scripts
# .../vcpkg
$vcpkgRoot = $PSScriptRoot `
    | Split-Path `
    | Split-Path `
    | Split-Path

$PortsTree = Get-Item $PortsTree

if (-not (Test-Path "$vcpkgRoot/.vcpkg-root"))
{
    Write-Error "The vcpkg root was not at $vcpkgRoot; did the script get moved?"
    throw
}

if (-not (Test-Path "$vcpkgRoot/vcpkg.exe"))
{
    & "$vcpkgRoot/bootstrap-vcpkg.bat"
    if (-not $?)
    {
        Write-Error "Bootstrapping vcpkg failed"
        throw
    }
}

& "$vcpkgRoot/vcpkg.exe" 'x-format-manifest' '--all'
$changedFiles = & "$PSScriptRoot/Get-ChangedFiles.ps1" -Directory $PortsTree
if (-not $IgnoreErrors -and $null -ne $changedFiles)
{
    $msg = @(
        "",
        "The formatting of the manifest files didn't match our expectation.",
        "If your build fails here, you need to run:"
    )
    $msg += "    vcpkg x-format-manifest --all"
    $msg += ""

    $msg += "vcpkg should produce the following diff:"
    $msg += git diff $Toolsrc

    Write-Error ($msg -join "`n")
    throw
}
