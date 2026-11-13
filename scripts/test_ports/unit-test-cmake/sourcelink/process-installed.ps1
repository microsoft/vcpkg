param (
    [Parameter(Mandatory = $true)][string]$Script,
    [Parameter(Mandatory = $true)][string]$TestRoot
)

$ErrorActionPreference = 'Stop'
$hostExe = (Get-Process -Id $PID).Path
$triplet = Join-Path $TestRoot 'installed triplet'
$scan = Join-Path $triplet 'share\sourcelink'
$output = Join-Path $TestRoot 'merged.json'
$fragment = Join-Path $scan 'sample.json'
New-Item -ItemType Directory -Force -Path $scan | Out-Null
$arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$Script`" -InstalledTripletPath `"$triplet`" -RelativeScan `"share\sourcelink`" -OutputFile `"$output`""

function Start-Merge([string]$Name) {
    $stdout = Join-Path $TestRoot "$Name.out.log"
    $stderr = Join-Path $TestRoot "$Name.err.log"
    $process = Start-Process -FilePath $hostExe -ArgumentList $arguments -PassThru -NoNewWindow `
        -RedirectStandardOutput $stdout -RedirectStandardError $stderr
    # Keep the handle open so Windows PowerShell can retrieve the exit code after termination.
    $null = $process.Handle
    return @{ Process = $process; Stdout = $stdout; Stderr = $stderr }
}

function Wait-Merge($Run, [bool]$ShouldSucceed = $true) {
    $Run.Process.WaitForExit()
    if (($Run.Process.ExitCode -eq 0) -ne $ShouldSucceed) {
        throw "Unexpected exit code $($Run.Process.ExitCode): $(Get-Content -LiteralPath $Run.Stdout, $Run.Stderr -Raw)"
    }
}

$mapping = '{"documents":{"__VCPKG_INSTALLED_TRIPLET_DIR__\\include\\sample\\*":"https://example.invalid/current/*"}}'
$stale = '{"documents":{"old":"https://example.invalid/old"}}'
[IO.File]::WriteAllText($fragment, $mapping)
if (Test-Path -LiteralPath $output) {
    Remove-Item -LiteralPath $output -Force
}

# Concurrent creation and replacement must both publish the requested mapping.
foreach ($mode in @('create', 'replace')) {
    if ($mode -eq 'replace') {
        [IO.File]::WriteAllText($output, $stale)
    }
    $runs = @(1..4 | ForEach-Object { Start-Merge "$mode-$_" })
    foreach ($run in $runs) {
        Wait-Merge $run
    }
    $documents = (Get-Content -LiteralPath $output -Raw | ConvertFrom-Json).documents
    $key = "$triplet\include\sample\*"
    if ($documents.$key -cne 'https://example.invalid/current/*' -or @($documents.PSObject.Properties).Count -ne 1) {
        throw "Incorrect merged mappings: $(Get-Content -LiteralPath $output -Raw)"
    }
}

$timestamp = (Get-Item -LiteralPath $output).LastWriteTimeUtc
Wait-Merge (Start-Merge 'unchanged')
if ((Get-Item -LiteralPath $output).LastWriteTimeUtc -ne $timestamp) {
    throw 'Unchanged mappings must preserve the output timestamp'
}

# A readable but non-replaceable stale file must not be reported as a successful merge.
[IO.File]::WriteAllText($output, $stale)
$lock = [IO.File]::Open($output, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
try {
    Wait-Merge (Start-Merge 'locked') $false
    if ([IO.File]::ReadAllText($output) -cne $stale) {
        throw 'A failed replacement changed the existing file'
    }
} finally {
    $lock.Dispose()
}
Wait-Merge (Start-Merge 'unlocked')

[IO.File]::WriteAllText($fragment, '{invalid')
Wait-Merge (Start-Merge 'invalid-json') $false
Remove-Item -LiteralPath $fragment
Remove-Item -LiteralPath $scan
Wait-Merge (Start-Merge 'no-fragments')
if ([IO.File]::ReadAllText($output) -cne '{"documents":{}}') {
    throw 'Removing all fragments must clear the previous mappings'
}

Write-Host 'Source Link installed-file tests passed'
