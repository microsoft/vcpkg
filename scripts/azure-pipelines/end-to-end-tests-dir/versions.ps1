. $PSScriptRoot/../end-to-end-tests-prelude.ps1

# Test verify versions
mkdir $VersionFilesRoot
Copy-Item -Recurse "scripts/testing/version-files/versions_incomplete" $VersionFilesRoot
$portsRedirectArgsOK = @(
    "--feature-flags=versions",
    "--x-builtin-ports-root=scripts/testing/version-files/ports",
    "--x-builtin-registry-versions-dir=scripts/testing/version-files/versions"
)
$portsRedirectArgsIncomplete = @(
    "--feature-flags=versions",
    "--x-builtin-ports-root=scripts/testing/version-files/ports_incomplete",
    "--x-builtin-registry-versions-dir=$VersionFilesRoot/versions_incomplete"
)
$CurrentTest = "x-verify-ci-versions (All files OK)"
Write-Host $CurrentTest
./vcpkg $portsRedirectArgsOK x-ci-verify-versions --verbose
Throw-IfFailed

$CurrentTest = "x-verify-ci-versions (Incomplete)"
./vcpkg $portsRedirectArgsIncomplete x-ci-verify-versions --verbose 
Throw-IfNotFailed

$CurrentTest = "x-add-version cat"
# Do not fail if there's nothing to update
./vcpkg $portsRedirectArgsIncomplete x-add-version cat 
Throw-IfFailed

$CurrentTest = "x-add-version dog"
# Local version is not in baseline and versions file
./vcpkg $portsRedirectArgsIncomplete x-add-version dog 
Throw-IfFailed

$CurrentTest = "x-add-version duck"
# Missing versions file
./vcpkg $portsRedirectArgsIncomplete x-add-version duck
Throw-IfFailed

$CurrentTest = "x-add-version ferret"
# Missing versions file and missing baseline entry
./vcpkg $portsRedirectArgsIncomplete x-add-version ferret
Throw-IfFailed

$CurrentTest = "x-add-version fish (must fail)"
# Discrepancy between local SHA and SHA in fish.json. Requires --overwrite-version.
$out = ./vcpkg $portsRedirectArgsIncomplete x-add-version fish
Throw-IfNotFailed
$CurrentTest = "x-add-version fish --overwrite-version"
./vcpkg $portsRedirectArgsIncomplete x-add-version fish --overwrite-version
Throw-IfFailed

$CurrentTest = "x-add-version mouse"
# Missing baseline entry
./vcpkg $portsRedirectArgsIncomplete x-add-version mouse
Throw-IfFailed
# Validate changes
./vcpkg $portsRedirectArgsIncomplete x-ci-verify-versions --verbose
Throw-IfFailed

$CurrentTest = "default baseline"
$out = ./vcpkg $commonArgs "--feature-flags=versions" install --x-manifest-root=scripts/testing/version-files/default-baseline-1 2>&1 | Out-String
Throw-IfNotFailed
if ($out -notmatch ".*Error: while checking out baseline.*")
{
    $out
    throw "Expected to fail due to missing baseline"
}

git fetch https://github.com/vicroms/test-registries
foreach ($opt_registries in @("",",registries"))
{
    Write-Trace "testing baselines: $opt_registries"
    Refresh-TestRoot
    $CurrentTest = "without default baseline 2 -- enabling versions should not change behavior"
    Remove-Item -Recurse $buildtreesRoot/versioning -ErrorAction SilentlyContinue
    ./vcpkg $commonArgs "--feature-flags=versions$opt_registries" install `
        "--dry-run" `
        "--x-manifest-root=scripts/testing/version-files/without-default-baseline-2" `
        "--x-builtin-registry-versions-dir=scripts/testing/version-files/default-baseline-2/versions"
    Throw-IfFailed
    Require-FileNotExists $buildtreesRoot/versioning

    $CurrentTest = "default baseline 2"
    ./vcpkg $commonArgs "--feature-flags=versions$opt_registries" install `
        "--dry-run" `
        "--x-manifest-root=scripts/testing/version-files/default-baseline-2" `
        "--x-builtin-registry-versions-dir=scripts/testing/version-files/default-baseline-2/versions"
    Throw-IfFailed
    Require-FileExists $buildtreesRoot/versioning

    $CurrentTest = "using version features fails without flag"
    ./vcpkg $commonArgs "--feature-flags=-versions$opt_registries" install `
        "--dry-run" `
        "--x-manifest-root=scripts/testing/version-files/default-baseline-2" `
        "--x-builtin-registry-versions-dir=scripts/testing/version-files/default-baseline-2/versions"
    Throw-IfNotFailed
}
