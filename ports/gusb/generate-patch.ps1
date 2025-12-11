# Script to generate patch file from git diff in libgusb repo
# Usage: .\generate-patch.ps1

$ErrorActionPreference = "Stop"

# Determine paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)
$LibgusbRepo = Join-Path $ProjectRoot "libgusb"
$PatchFile = Join-Path $ScriptDir "fix-windows-build.patch"

Write-Host "Generating patch from git diff in libgusb..." -ForegroundColor Green

# Ensure repo exists
if (-not (Test-Path $LibgusbRepo)) {
    Write-Host "Error: libgusb directory not found at $LibgusbRepo" -ForegroundColor Red
    exit 1
}

Push-Location $LibgusbRepo

try {
    $changes = git status --short
    if ([string]::IsNullOrWhiteSpace($changes)) {
        Write-Host "Warning: No changes detected in libgusb" -ForegroundColor Yellow
        Write-Host "Make sure you have made the necessary changes first." -ForegroundColor Yellow
        exit 0
    }

    Write-Host "Changes detected:" -ForegroundColor Cyan
    git status --short

    Write-Host "`nGenerating patch file..." -ForegroundColor Cyan
    git diff --no-color HEAD | Out-File -FilePath $PatchFile -Encoding ASCII

    if (-not (Test-Path $PatchFile)) {
        Write-Host "Error: Failed to create patch file" -ForegroundColor Red
        exit 1
    }

    $patchSize = (Get-Item $PatchFile).Length
    if ($patchSize -eq 0) {
        Write-Host "Warning: Patch file is empty" -ForegroundColor Yellow
        Remove-Item $PatchFile
        exit 1
    }

    Write-Host "`nPatch file generated successfully:" -ForegroundColor Green
    Write-Host "  $PatchFile" -ForegroundColor Cyan
    Write-Host "  Size: $patchSize bytes" -ForegroundColor Cyan

    $patchContent = Get-Content $PatchFile -Raw
    $fileCount = ([regex]::Matches($patchContent, "diff --git")).Count
    Write-Host "`nPatch summary:" -ForegroundColor Cyan
    Write-Host "  Files changed: $fileCount" -ForegroundColor Cyan
}
finally {
    Pop-Location
}

Write-Host "`nDone!" -ForegroundColor Green


