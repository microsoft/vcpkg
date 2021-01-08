. $PSScriptRoot/../end-to-end-tests-prelude.ps1

# Test verify versions
mkdir $VersionFilesRoot
Copy-Item -Recurse "scripts/testing/version-files/port_versions_incomplete" $VersionFilesRoot
$portsRedirectArgsOK = @(
    "--feature-flags=versions",
    "--x-builtin-ports-root=scripts/testing/version-files/ports",
    "--x-builtin-port-versions-dir=scripts/testing/version-files/port_versions"
)
$portsRedirectArgsIncomplete = @(
    "--feature-flags=versions",
    "--x-builtin-ports-root=scripts/testing/version-files/ports_incomplete",
    "--x-builtin-port-versions-dir=$VersionFilesRoot/port_versions_incomplete"
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
$out = ./vcpkg $commonArgs "--feature-flags=versions" install --x-manifest-root=scripts/testing/version-files/default-baseline-1
Throw-IfNotFailed
# if ($out -notmatch "Error: while checking out baseline" -or $out -notmatch " does not exist in ")
# {
#     $out
#     throw "Expected to fail due to missing baseline"
# }

git fetch https://github.com/vicroms/test-registries
$CurrentTest = "default baseline"
./vcpkg $commonArgs "--feature-flags=versions" install `
    "--x-manifest-root=scripts/testing/version-files/default-baseline-2" `
    "--x-builtin-port-versions-dir=scripts/testing/version-files/default-baseline-2/port_versions"
Throw-IfFailed
