if ($IsLinux) {
    # The tests below need a mono installation not currently available on the Linux agents.
    return
}

. $PSScriptRoot/../end-to-end-tests-prelude.ps1

# Test simple installation
Run-Vcpkg -TestArgs ($commonArgs + @("install", "rapidjson", "--binarycaching", "--x-binarysource=clear;files,$ArchiveRoot,write;nuget,$NuGetRoot,readwrite"))
Throw-IfFailed
Require-FileExists "$installRoot/$Triplet/include/rapidjson/rapidjson.h"

# Test simple removal
Run-Vcpkg -TestArgs ($commonArgs + @("remove", "rapidjson"))
Throw-IfFailed
Require-FileNotExists "$installRoot/$Triplet/include/rapidjson/rapidjson.h"

# Test restoring from files archive
Remove-Item -Recurse -Force $installRoot
Remove-Item -Recurse -Force $buildtreesRoot
Run-Vcpkg -TestArgs ($commonArgs + @("install","rapidjson","--binarycaching","--x-binarysource=clear;files,$ArchiveRoot,read"))
Throw-IfFailed
Require-FileExists "$installRoot/$Triplet/include/rapidjson/rapidjson.h"
Require-FileNotExists "$buildtreesRoot/rapidjson/src"
Require-FileExists "$buildtreesRoot/detect_compiler"

# Test --no-binarycaching
Remove-Item -Recurse -Force $installRoot
Remove-Item -Recurse -Force $buildtreesRoot
Run-Vcpkg -TestArgs ($commonArgs + @("install","rapidjson","--no-binarycaching","--x-binarysource=clear;files,$ArchiveRoot,read"))
Throw-IfFailed
Require-FileExists "$installRoot/$Triplet/include/rapidjson/rapidjson.h"
Require-FileExists "$buildtreesRoot/rapidjson/src"
Require-FileExists "$buildtreesRoot/detect_compiler"

# Test --editable
Remove-Item -Recurse -Force $installRoot
Remove-Item -Recurse -Force $buildtreesRoot
Run-Vcpkg -TestArgs ($commonArgs + @("install","rapidjson","--editable","--x-binarysource=clear;files,$ArchiveRoot,read"))
Throw-IfFailed
Require-FileExists "$installRoot/$Triplet/include/rapidjson/rapidjson.h"
Require-FileExists "$buildtreesRoot/rapidjson/src"
Require-FileNotExists "$buildtreesRoot/detect_compiler"

# Test restoring from nuget
Remove-Item -Recurse -Force $installRoot
Remove-Item -Recurse -Force $buildtreesRoot
Run-Vcpkg -TestArgs ($commonArgs + @("install", "rapidjson", "--binarycaching", "--x-binarysource=clear;nuget,$NuGetRoot"))
Throw-IfFailed
Require-FileExists "$installRoot/$Triplet/include/rapidjson/rapidjson.h"
Require-FileNotExists "$buildtreesRoot/rapidjson/src"

# Test four-phase flow
Remove-Item -Recurse -Force $installRoot -ErrorAction SilentlyContinue
Run-Vcpkg -TestArgs ($commonArgs + @("install", "rapidjson", "--dry-run", "--x-write-nuget-packages-config=$TestingRoot/packages.config"))
Throw-IfFailed
Require-FileNotExists "$installRoot/$Triplet/include/rapidjson/rapidjson.h"
Require-FileNotExists "$buildtreesRoot/rapidjson/src"
Require-FileExists "$TestingRoot/packages.config"
if ($IsLinux -or $IsMacOS) {
    mono $(./vcpkg fetch nuget) restore $TestingRoot/packages.config -OutputDirectory "$NuGetRoot2" -Source "$NuGetRoot"
} else {
    & $(./vcpkg fetch nuget) restore $TestingRoot/packages.config -OutputDirectory "$NuGetRoot2" -Source "$NuGetRoot"
}
Throw-IfFailed
Remove-Item -Recurse -Force $NuGetRoot -ErrorAction SilentlyContinue
mkdir $NuGetRoot
Run-Vcpkg -TestArgs ($commonArgs + @("install", "rapidjson", "tinyxml", "--binarycaching", "--x-binarysource=clear;nuget,$NuGetRoot2;nuget,$NuGetRoot,write"))
Throw-IfFailed
Require-FileExists "$installRoot/$Triplet/include/rapidjson/rapidjson.h"
Require-FileExists "$installRoot/$Triplet/include/tinyxml.h"
Require-FileNotExists "$buildtreesRoot/rapidjson/src"
Require-FileExists "$buildtreesRoot/tinyxml/src"
if ((Get-ChildItem $NuGetRoot -Filter '*.nupkg' | Measure-Object).Count -ne 1) {
    throw "In '$CurrentTest': did not create exactly 1 NuGet package"
}

# Test export
$CurrentTest = 'Exporting'
Require-FileNotExists "$TestingRoot/vcpkg-export-output"
Require-FileNotExists "$TestingRoot/vcpkg-export.1.0.0.nupkg"
Require-FileNotExists "$TestingRoot/vcpkg-export-output.zip"
Run-Vcpkg -TestArgs ($commonArgs + @("export", "rapidjson", "tinyxml", "--nuget", "--nuget-id=vcpkg-export", "--nuget-version=1.0.0", "--output=vcpkg-export-output", "--raw", "--zip", "--output-dir=$TestingRoot"))
Require-FileExists "$TestingRoot/vcpkg-export-output"
Require-FileExists "$TestingRoot/vcpkg-export.1.0.0.nupkg"
Require-FileExists "$TestingRoot/vcpkg-export-output.zip"
