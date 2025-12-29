# Script to generate patch file from git diff in libfprint_repo
# Usage: .\generate-patch.ps1

$ErrorActionPreference = "Stop"

# Get the script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)
$LibFprintRepo = Join-Path $ProjectRoot "libfprint_repo"
$PatchFile = Join-Path $ScriptDir "fix-windows-build.patch"

Write-Host "Generating patch from git diff in libfprint_repo..." -ForegroundColor Green

# Check if libfprint_repo exists
if (-not (Test-Path $LibFprintRepo)) {
    Write-Host "Error: libfprint_repo directory not found at $LibFprintRepo" -ForegroundColor Red
    exit 1
}

# Change to libfprint_repo directory
Push-Location $LibFprintRepo

try {
    # Check if there are any changes
    $changes = git status --short
    if ([string]::IsNullOrWhiteSpace($changes)) {
        Write-Host "Warning: No changes detected in libfprint_repo" -ForegroundColor Yellow
        Write-Host "Make sure you have made the necessary changes first." -ForegroundColor Yellow
        exit 0
    }

    Write-Host "Changes detected:" -ForegroundColor Cyan
    git status --short

    # Generate patch from git diff (include staged files)
    Write-Host "`nGenerating patch file..." -ForegroundColor Cyan
    # Combine both unstaged and staged changes
    $unstagedDiff = git diff --no-color
    $stagedDiff = git diff --cached --no-color
    ($unstagedDiff + "`n" + $stagedDiff) | Out-File -FilePath $PatchFile -Encoding ASCII

    # Check if patch file was created and has content
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

    # Validate patch format (try to apply in a temporary location)
    Write-Host "Validating patch format..." -ForegroundColor Cyan
    $tempDir = Join-Path $env:TEMP "libfprint-patch-validation"
    if (Test-Path $tempDir) {
        Remove-Item -Recurse -Force $tempDir
    }
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    
    try {
        # Try to apply patch in temp directory (this will fail but shows if format is valid)
        Push-Location $tempDir
        git init | Out-Null
        $validation = git apply --check $PatchFile 2>&1
        if ($LASTEXITCODE -ne 0 -and $validation -notmatch "No valid patches") {
            Write-Host "Warning: Patch validation failed:" -ForegroundColor Yellow
            Write-Host $validation
        } else {
            Write-Host "Patch format is valid!" -ForegroundColor Green
        }
    } catch {
        Write-Host "Warning: Could not validate patch format, but file was created." -ForegroundColor Yellow
    } finally {
        Pop-Location
        if (Test-Path $tempDir) {
            Remove-Item -Recurse -Force $tempDir
        }
    }

    Write-Host "`nPatch file generated successfully:" -ForegroundColor Green
    Write-Host "  $PatchFile" -ForegroundColor Cyan
    Write-Host "  Size: $patchSize bytes" -ForegroundColor Cyan

    # Show summary
    Write-Host "`nPatch summary:" -ForegroundColor Cyan
    $patchContent = Get-Content $PatchFile -Raw
    $fileCount = ([regex]::Matches($patchContent, "diff --git")).Count
    Write-Host "  Files changed: $fileCount" -ForegroundColor Cyan

} finally {
    Pop-Location
}

Write-Host "`nDone!" -ForegroundColor Green

