. $PSScriptRoot/../end-to-end-tests-prelude.ps1

# Test that prohibiting backcompat features actually prohibits
$backcompatFeaturePorts = @('vcpkg-uses-test-cmake', 'vcpkg-uses-vcpkg-common-functions')
foreach ($backcompatFeaturePort in $backcompatFeaturePorts) {
    $succeedArgs = $commonArgs + @('install',$backcompatFeaturePort,'--no-binarycaching')
    $failArgs = $succeedArgs + @('--x-prohibit-backcompat-features')
    $CurrentTest = "Should fail: ./vcpkg $($failArgs -join ' ')"
    Run-Vcpkg @failArgs
    if ($LastExitCode -ne 0) {
        Write-Host "... failed (this is good!)."
    } else {
        throw $CurrentTest
    }

    # Install failed when prohibiting backcompat features, so it should succeed if we allow them
    $CurrentTest = "Should succeeed: ./vcpkg $($succeedArgs -join ' ')"
    Run-Vcpkg @succeedArgs
    if ($LastExitCode -ne 0) {
        throw $CurrentTest
    } else {
        Write-Host "... succeeded."
    }
}
