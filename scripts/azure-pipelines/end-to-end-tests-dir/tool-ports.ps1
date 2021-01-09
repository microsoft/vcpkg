. $PSScriptRoot/../end-to-end-tests-prelude.ps1

$commonArgs += @("--x-binarysource=clear")

$hostTriplet = "$Triplet"
$env:VCPKG_DEFAULT_HOST_TRIPLET = "$hostTriplet"
if (!$IsLinux -and !$IsMacOS)
{
    $targetTriplet = "x64-windows-e2e"
}
elseif ($IsMacOS)
{
    $targetTriplet = "x64-osx-e2e"
}
else
{
    $targetTriplet = "x64-linux-e2e"
}

$env:VCPKG_FEATURE_FLAGS="-compilertracking"

# Test native installation
./vcpkg $commonArgs install tool-libb
Throw-IfFailed
@("tool-control", "tool-manifest", "tool-liba", "tool-libb") | % {
    Require-FileNotExists $installRoot/$targetTriplet/share/$_
    Require-FileExists $installRoot/$hostTriplet/share/$_
}

Refresh-TestRoot

# Test cross installation
./vcpkg $commonArgs install "tool-libb:$targetTriplet"
Throw-IfFailed
@("tool-control", "tool-manifest", "tool-liba") | % {
    Require-FileNotExists $installRoot/$targetTriplet/share/$_
    Require-FileExists $installRoot/$hostTriplet/share/$_
}
@("tool-libb") | % {
    Require-FileExists $installRoot/$targetTriplet/share/$_
    Require-FileNotExists $installRoot/$hostTriplet/share/$_
}

# Test removal of packages in cross installation
./vcpkg $commonArgs "remove" "tool-manifest" "--recurse"
Throw-IfFailed
@("tool-control", "tool-liba") | % {
    Require-FileNotExists $installRoot/$targetTriplet/share/$_
    Require-FileExists $installRoot/$hostTriplet/share/$_
}
@("tool-libb", "tool-manifest") | % {
    Require-FileNotExists $installRoot/$targetTriplet/share/$_
    Require-FileNotExists $installRoot/$hostTriplet/share/$_
}

Refresh-TestRoot

# Test VCPKG_DEFAULT_HOST_TRIPLET
$env:VCPKG_DEFAULT_HOST_TRIPLET = $targetTriplet
./vcpkg $commonArgs "install" "tool-libb:$hostTriplet"
Throw-IfFailed
@("tool-control", "tool-manifest", "tool-liba") | % {
    Require-FileExists $installRoot/$targetTriplet/share/$_
    Require-FileNotExists $installRoot/$hostTriplet/share/$_
}
@("tool-libb") | % {
    Require-FileNotExists $installRoot/$targetTriplet/share/$_
    Require-FileExists $installRoot/$hostTriplet/share/$_
}

Refresh-TestRoot

Remove-Item env:VCPKG_DEFAULT_HOST_TRIPLET
# Test --host-triplet
./vcpkg $commonArgs "install" "tool-libb:$hostTriplet" "--host-triplet=$targetTriplet"
Throw-IfFailed
@("tool-control", "tool-manifest", "tool-liba") | % {
    Require-FileExists $installRoot/$targetTriplet/share/$_
    Require-FileNotExists $installRoot/$hostTriplet/share/$_
}
@("tool-libb") | % {
    Require-FileNotExists $installRoot/$targetTriplet/share/$_
    Require-FileExists $installRoot/$hostTriplet/share/$_
}
