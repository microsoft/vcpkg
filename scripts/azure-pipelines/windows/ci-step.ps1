# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#

<#
.SYNOPSIS
Runs the bootstrap and port install parts of the vcpkg CI for Windows

.DESCRIPTION
There are multiple steps to the vcpkg CI; this is the most important one.
First, it runs `boostrap-vcpkg.bat` in order to build the tool itself; it
then installs either all of the ports specified, or all of the ports excluding
those which are passed in $ExcludePorts. Then, it runs `vcpkg ci` to access the
data, and prints all of the failures and successes to the Azure console.

.PARAMETER Triplet
The triplet to run the installs for -- one of the triplets known by vcpkg, like
`x86-windows` and `x64-windows`.

.PARAMETER OnlyIncludePorts
The set of ports to install.

.PARAMETER ExcludePorts
If $OnlyIncludePorts is not passed, this set of ports is used to exclude ports to
install from the set of all ports.

.PARAMETER AdditionalVcpkgFlags
Flags to pass to vcpkg in addition to the ports to install, and the triplet.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Triplet,
    [string]$OnlyIncludePorts = '',
    [string]$ExcludePorts = '',
    [string]$AdditionalVcpkgFlags = ''
)

Set-StrictMode -Version Latest

$scriptsDir = Split-Path -parent $script:MyInvocation.MyCommand.Definition

<#
.SYNOPSIS
Gets the first parent directory D of $startingDir such that D/$filename is a file.

.DESCRIPTION
Get-FileRecursivelyUp Looks for a directory containing $filename, starting in
$startingDir, and then checking each parent directory of $startingDir in turn.
It returns the first directory it finds.
If the file is not found, the empty string is returned - this is likely to be
a bug.

.PARAMETER startingDir
The directory to start looking for $filename in.

.PARAMETER filename
The filename to look for.
#>
function Get-FileRecursivelyUp() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$startingDir,
        [Parameter(Mandatory = $true)][string]$filename
    )

    $currentDir = $startingDir

    while ($currentDir.Length -gt 0 -and -not (Test-Path "$currentDir\$filename")) {
        Write-Verbose "Examining $currentDir for $filename"
        $currentDir = Split-Path $currentDir -Parent
    }

    if ($currentDir.Length -eq 0) {
        Write-Warning "None of $startingDir's parent directories contain $filename. This is likely a bug."
    }

    Write-Verbose "Examining $currentDir for $filename - Found"
    return $currentDir
}

<#
.SYNOPSIS
Removes a file or directory, with backoff in the directory case.

.DESCRIPTION
Remove-Item -Recurse occasionally fails spuriously; in order to get around this,
we remove with backoff. At a maximum, we will wait 180s before giving up.

.PARAMETER Path
The path to remove.
#>
function Remove-VcpkgItem {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$Path)

    if ([string]::IsNullOrEmpty($Path)) {
        return
    }

    if (Test-Path $Path) {
        # Remove-Item -Recurse occasionally fails. This is a workaround
        if ((Get-Item $Path) -is [System.IO.DirectoryInfo]) {
            Remove-Item $Path -Force -Recurse -ErrorAction SilentlyContinue
            for ($i = 0; $i -le 60 -and (Test-Path $Path); $i++) { # ~180s max wait time
                Start-Sleep -m (100 * $i)
                Remove-Item $Path -Force -Recurse -ErrorAction SilentlyContinue
            }

            if (Test-Path $Path) {
                Write-Error "$Path was unable to be fully deleted."
                throw;
            }
        }
        else {
            Remove-Item $Path -Force
        }
    }
}

$vcpkgRootDir = Get-FileRecursivelyUp $scriptsDir .vcpkg-root

Write-Host "Bootstrapping vcpkg ..."
& "$vcpkgRootDir\bootstrap-vcpkg.bat" -Verbose
if (!$?) { throw "bootstrap failed" }
Write-Host "Bootstrapping vcpkg ... done."

$ciXmlPath = "$vcpkgRootDir\test-full-ci.xml"
$consoleOuputPath = "$vcpkgRootDir\console-out.txt"
Remove-VcpkgItem $ciXmlPath

$env:VCPKG_FEATURE_FLAGS = "binarycaching"

if (![string]::IsNullOrEmpty($OnlyIncludePorts)) {
    ./vcpkg install --triplet $Triplet $OnlyIncludePorts $AdditionalVcpkgFlags `
        "--x-xunit=$ciXmlPath" | Tee-Object -FilePath "$consoleOuputPath"
}
else {
    $exclusions = ""
    if (![string]::IsNullOrEmpty($ExcludePorts)) {
        $exclusions = "--exclude=$ExcludePorts"
    }

    if ( $Triplet -notmatch "x86-windows" -and $Triplet -notmatch "x64-windows" ) {
        # WORKAROUND: the x86-windows flavors of these are needed for all
        # cross-compilation, but they are not auto-installed.
        # Install them so the CI succeeds
        ./vcpkg install "protobuf:x86-windows" "boost-build:x86-windows" "sqlite3:x86-windows"
        if (-not $?) { throw "Failed to install protobuf & boost-build & sqlite3" }
    }

    # Turn all error messages into strings for output in the CI system.
    # This is needed due to the way the public Azure DevOps turns error output to pipeline errors,
    # even when told to ignore error output.
    ./vcpkg ci $Triplet $AdditionalVcpkgFlags "--x-xunit=$ciXmlPath" $exclusions 2>&1 `
    | ForEach-Object {
        if ($_ -is [System.Management.Automation.ErrorRecord]) { $_.ToString() } else { $_ }
    }

    # Phasing out the console output (it is already saved in DevOps) Create a dummy file for now.
    Set-Content -LiteralPath "$consoleOuputPath" -Value ''
}

Write-Host "CI test is complete"
