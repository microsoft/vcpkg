[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$Root
)

if (-not (Test-Path "$Root/.vcpkg-root"))
{
    Write-Error "The vcpkg root was not at $Root"
    throw
}

& "$Root/docs/regenerate.ps1" -VcpkgRoot $Root -WarningAction 'Stop'

$changedFiles = & "$PSScriptRoot/Get-ChangedFiles.ps1" -Directory "$Root/docs"
if ($null -ne $changedFiles)
{
    $msg = @(
        "",
        "The documentation files do not seem to have been regenerated.",
        "Please re-run `docs/regenerate.ps1`."
    )
    $msg += ""

    $msg += "This should produce the following diff:"
    $msg += git diff "$Root/docs"

    Write-Error ($msg -join "`n")
    throw
}
