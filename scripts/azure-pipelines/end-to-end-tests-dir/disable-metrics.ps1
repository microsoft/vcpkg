. $PSScriptRoot/../end-to-end-tests-prelude.ps1

# Test that metrics are on by default
$metricsTagName = 'vcpkg.disable-metrics'
$metricsAreDisabledMessage = 'Warning: passed --sendmetrics, but metrics are disabled.'

function Test-Metrics-Enabled() {
    Param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$TestArgs
    )

    $actualArgs = @('version', '--sendmetrics')
    if ($TestArgs.Length -ne 0) {
        $actualArgs += $TestArgs
    }

    $vcpkgOutput = Run-Vcpkg $actualArgs
    if ($vcpkgOutput -contains $metricsAreDisabledMessage) {
        Write-Host 'Metrics are disabled'
        return $false
    }

    Write-Host 'Metrics are enabled'
    return $true
}

# By default, metrics are enabled.
Require-FileNotExists $metricsTagName
if (-Not (Test-Metrics-Enabled)) {
    throw "Metrics were not on by default."
}

if (Test-Metrics-Enabled '--disable-metrics') {
    throw "Metrics were not disabled by switch."
}

$env:VCPKG_DISABLE_METRICS = 'ON'
try {
    if (Test-Metrics-Enabled) {
        throw "Environment variable did not disable metrics."
    }

    # Also test that you get no message without --sendmetrics
    $vcpkgOutput = Run-Vcpkg list
    if ($vcpkgOutput -contains $metricsAreDisabledMessage) {
        throw "Disabled metrics emit message even without --sendmetrics"
    }

    if (-Not (Test-Metrics-Enabled '--no-disable-metrics')) {
        throw "Environment variable to disable metrics could not be overridden by switch."
    }
} finally {
    Remove-Item env:VCPKG_DISABLE_METRICS
}

# If the disable-metrics tag file exists, metrics are disabled even if attempted to be enabled on
# the command line.
Set-Content -Path $metricsTagName -Value ""
try {
    if (Test-Metrics-Enabled '--disable-metrics') {
        throw "Metrics were not force-disabled by the disable-metrics tag file."
    }
}
finally {
    Remove-Item $metricsTagName
}
