. $PSScriptRoot/../end-to-end-tests-prelude.ps1

$successCases = @('vcpkg-requires-current-date', 'vcpkg-requires-old-date')
foreach ($successCase in $successCases) {
    $CurrentTest = "Should succeeed: ./vcpkg install $successCase"
    Write-Host $CurrentTest
    Run-Vcpkg install $successCase @commonArgs
    if ($LastExitCode -ne 0) {
        throw $CurrentTest
    } else {
        Write-Host "... succeeded."
    }
}

$CurrentTest = "Should fail: ./vcpkg install vcpkg-requires-future-date"
Write-Host $CurrentTest
Run-Vcpkg install vcpkg-requires-future-date @commonArgs
if ($LastExitCode -ne 0) {
    Write-Host "... failed (this is good!)."
} else {
    throw $CurrentTest
}
