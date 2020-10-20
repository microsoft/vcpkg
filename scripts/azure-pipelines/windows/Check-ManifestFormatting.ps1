[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$Root,
    [Parameter()]
    [switch]$IgnoreErrors # allows one to just format
)

$portsTree = Get-Item "$Root/ports"

if (-not (Test-Path "$Root/.vcpkg-root"))
{
    Write-Error "The vcpkg root was not at $Root"
    throw
}

if (-not (Test-Path "$Root/vcpkg.exe"))
{
    & "$Root/bootstrap-vcpkg.bat"
    if (-not $?)
    {
        Write-Error "Bootstrapping vcpkg failed"
        throw
    }
}

& "$Root/vcpkg.exe" 'format-manifest' '--all'
if (-not $?)
{
    Write-Error "Failed formatting manifests; are they well-formed?"
    throw
}

$changedFiles = & "$PSScriptRoot/Get-ChangedFiles.ps1" -Directory $portsTree
if (-not $IgnoreErrors -and $null -ne $changedFiles)
{
    $msg = @(
        "",
        "The formatting of the manifest files didn't match our expectation.",
        "See github.com/microsoft/vcpkg/blob/master/docs/maintainers/maintainer-guide.md#manifest for solution."
    )
    $msg += ""

    $msg += "vcpkg should produce the following diff:"
    $msg += git diff $portsTree

    Write-Error ($msg -join "`n")
    throw
}
