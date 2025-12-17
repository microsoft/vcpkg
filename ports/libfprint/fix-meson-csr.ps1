<#
.SYNOPSIS
    Fixes Meson bug that incorrectly adds "csr" to LINK_ARGS for static libraries on Windows ARM64.

.DESCRIPTION
    This script removes the erroneous "LINK_ARGS = `"csr`"" lines from build.ninja file.
    This is a known Meson bug where it incorrectly sets LINK_ARGS="csr" for MSVC static libraries
    on Windows ARM64, causing linker error LNK1181.

.PARAMETER BuildDir
    Path to the build directory containing build.ninja file.

.EXAMPLE
    .\fix-meson-csr.ps1 -BuildDir "E:\vcpkg\buildtrees\libfprint\arm64-windows-dbg"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$BuildDir
)

$ErrorActionPreference = "Stop"

# Validate build directory exists
if (-not (Test-Path -Path $BuildDir -PathType Container)) {
    Write-Error "Build directory does not exist: $BuildDir"
    exit 1
}

# Path to build.ninja
$buildNinjaPath = Join-Path -Path $BuildDir -ChildPath "build.ninja"

# Validate build.ninja exists
if (-not (Test-Path -Path $buildNinjaPath -PathType Leaf)) {
    Write-Error "build.ninja not found at: $buildNinjaPath"
    exit 1
}

Write-Host "Fixing Meson 'csr' bug in build.ninja..." -ForegroundColor Cyan
Write-Host "  Path: $buildNinjaPath" -ForegroundColor Gray

try {
    # Read file content as raw text to preserve line endings
    $content = Get-Content -Path $buildNinjaPath -Raw -Encoding UTF8

    # Count occurrences before fix
    $beforeCount = ([regex]::Matches($content, '(?m)^\s*LINK_ARGS\s*=\s*"csr"\s*$')).Count

    if ($beforeCount -eq 0) {
        Write-Host "  No 'csr' LINK_ARGS found. Nothing to fix." -ForegroundColor Green
        exit 0
    }

    Write-Host "  Found $beforeCount occurrence(s) of LINK_ARGS = `"csr`"" -ForegroundColor Yellow

    # First, fix STATIC_LINKER rule format BEFORE removing LINK_ARGS
    # Current format: lib.exe "-machine:ARM64" "-nologo" $LINK_ARGS $out $in
    # Should be: lib.exe "-machine:ARM64" "-nologo" $LINK_ARGS $in /OUT:$out
    # We fix format first to put output after input with /OUT: prefix
    Write-Host "  Fixing STATIC_LINKER rule format..." -ForegroundColor Yellow
    $content = $content -replace '(?m)(rule STATIC_LINKER\s+command\s*=\s*.*lib\.exe.*-nologo"\s+)\$LINK_ARGS\s+\$out\s+\$in', '$1$LINK_ARGS $in /OUT:$out'

    # Remove lines matching: LINK_ARGS = "csr" (with optional whitespace)
    # Using multiline regex to match across line boundaries
    $content = $content -replace '(?m)^\s*LINK_ARGS\s*=\s*"csr"\s*$\r?\n', ''
    
    # After removing LINK_ARGS="csr", fix any remaining broken format
    # Pattern: $out $in (broken) should be $in /OUT:$out
    if ($content -match '(?m)rule STATIC_LINKER\s+command\s*=\s*.*lib\.exe.*-nologo"\s+\$out\s+\$in') {
        Write-Host "  Fixing remaining broken STATIC_LINKER format..." -ForegroundColor Yellow
        $content = $content -replace '(?m)(rule STATIC_LINKER\s+command\s*=\s*.*lib\.exe.*-nologo"\s+)\$out\s+\$in', '$1$in /OUT:$out'
    }


    # Remove any double blank lines that might result from removal
    $content = $content -replace '(?m)\r?\n\r?\n\r?\n+', "`r`n`r`n"

    # Write back to file (preserve UTF8 encoding, no BOM for Ninja compatibility)
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($buildNinjaPath, $content, $utf8NoBom)

    # Verify fix
    $afterCount = ([regex]::Matches($content, '(?m)^\s*LINK_ARGS\s*=\s*"csr"\s*$')).Count

    if ($afterCount -eq 0) {
        Write-Host "  Successfully removed all 'csr' LINK_ARGS and fixed STATIC_LINKER rule." -ForegroundColor Green
        exit 0
    } else {
        Write-Warning "  Warning: $afterCount occurrence(s) still remain. Fix may be incomplete."
        exit 1
    }

} catch {
    Write-Error "Failed to fix build.ninja: $_"
    exit 1
}

