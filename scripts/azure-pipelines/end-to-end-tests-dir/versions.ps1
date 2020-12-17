. $PSScriptRoot/../end-to-end-tests-prelude.ps1

# Test verify versions
mkdir $VersionFilesRoot
Copy-Item -Recurse "scripts/testing/version-files/port_versions_incomplete" $VersionFilesRoot
$portsRedirectArgsOK = @(
    "--feature-flags=versions",
    "--x-builtin-ports-root=scripts/testing/version-files/ports",
    "--x-builtin-port-versions-root=scripts/testing/version-files/port_versions"
)
$portsRedirectArgsIncomplete = @(
    "--feature-flags=versions",
    "--x-builtin-ports-root=scripts/testing/version-files/ports_incomplete",
    "--x-builtin-port-versions-root=$VersionFilesRoot/port_versions_incomplete"
)
$CurrentTest = "x-verify-ci-versions (All files OK)"
Write-Host $CurrentTest
./vcpkg $portsRedirectArgsOK x-ci-verify-versions --verbose
Throw-IfFailed

$CurrentTest = "x-verify-ci-versions (Incomplete)"
./vcpkg $portsRedirectArgsIncomplete x-ci-verify-versions --verbose 
Throw-IfNotFailed
# Do not fail if there's nothing to update
./vcpkg $portsRedirectArgsIncomplete x-add-version cat 
Throw-IfFailed
# Local version is not in baseline and versions file
./vcpkg $portsRedirectArgsIncomplete x-add-version dog 
Throw-IfFailed
# Missing versions file
./vcpkg $portsRedirectArgsIncomplete x-add-version duck
Throw-IfFailed
# Missing versions file and missing baseline entry
./vcpkg $portsRedirectArgsIncomplete x-add-version ferret
Throw-IfFailed
# Missing baseline entry
./vcpkg $portsRedirectArgsIncomplete x-add-version mouse
Throw-IfFailed
# Validate changes
./vcpkg $portsRedirectArgsIncomplete x-ci-verify-versions --verbose
Throw-IfFailed
