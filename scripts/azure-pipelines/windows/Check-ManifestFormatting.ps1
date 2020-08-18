[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$Root,
    [Parameter()]
    [string]$DownloadsDirectory,
    [Parameter()]
    [switch]$IgnoreErrors # allows one to just format
)

$portsTree = Get-Item "$Root/ports"

if (-not (Test-Path "$Root/.vcpkg-root"))
{
    Write-Error "The vcpkg root was not at $Root"
    throw
}

if (-not [string]::IsNullOrEmpty($DownloadsDirectory))
{
    $env:VCPKG_DOWNLOADS = $DownloadsDirectory
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

& "$Root/vcpkg.exe" 'x-format-manifest' '--all'
$changedFiles = & "$PSScriptRoot/Get-ChangedFiles.ps1" -Directory $portsTree
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
    $msg += git diff $portsTree

    Write-Error ($msg -join "`n")
    throw
}
