# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#
<#
.SYNOPSIS
End-to-End tests for the vcpkg executable.

.DESCRIPTION
These tests cover the command line interface and broad functions of vcpkg, including `install`, `remove` and certain
binary caching scenarios. They use the vcpkg executable in the current directory.

.PARAMETER Triplet
The triplet to use for testing purposes.

.PARAMETER WorkingRoot
The location used as scratch space for testing.

#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Triplet,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$WorkingRoot
)

$ErrorActionPreference = "Stop"

$TestingRoot = Join-Path $WorkingRoot 'testing'
$buildtreesRoot = Join-Path $TestingRoot 'buildtrees'
$installRoot = Join-Path $TestingRoot 'installed'
$packagesRoot = Join-Path $TestingRoot 'packages'
$NuGetRoot = Join-Path $TestingRoot 'nuget'
$NuGetRoot2 = Join-Path $TestingRoot 'nuget2'
$ArchiveRoot = Join-Path $TestingRoot 'archives'
$commonArgs = @(
    "--triplet",
    $Triplet,
    "--x-buildtrees-root=$buildtreesRoot",
    "--x-install-root=$installRoot",
    "--x-packages-root=$packagesRoot",
    "--overlay-ports=scripts/e2e_ports"
)
$CurrentTest = 'unassigned'

function Refresh-TestRoot {
    Remove-Item -Recurse -Force $TestingRoot -ErrorAction SilentlyContinue
    mkdir $TestingRoot
    mkdir $NuGetRoot
}

function Require-FileExists {
    [CmdletBinding()]
    Param(
        [string]$File
    )
    if (-Not (Test-Path $File)) {
        throw "'$CurrentTest' failed to create file '$File'"
    }
}

function Require-FileNotExists {
    [CmdletBinding()]
    Param(
        [string]$File
    )
    if (Test-Path $File) {
        throw "'$CurrentTest' should not have created file '$File'"
    }
}

function Throw-IfFailed {
    if ($LASTEXITCODE -ne 0) {
        throw "'$CurrentTest' had a step with a nonzero exit code"
    }
}

function Throw-IfNotFailed {
    if ($LASTEXITCODE -eq 0) {
        throw "'$CurrentTest' had a step with an unexpectedly zero exit code"
    }
}

function Run-Vcpkg {
    param([string[]]$TestArgs)
    $CurrentTest = "./vcpkg $($testArgs -join ' ')"
    Write-Host $CurrentTest
    ./vcpkg @testArgs
}

##### Test spaces in the path
Refresh-TestRoot
$CurrentTest = "zlib with spaces in path"
Write-Host $CurrentTest
./vcpkg install zlib "--triplet" $Triplet `
    "--no-binarycaching" `
    "--x-buildtrees-root=$TestingRoot/build Trees" `
    "--x-install-root=$TestingRoot/instalL ed" `
    "--x-packages-root=$TestingRoot/packaG es"
Throw-IfFailed

##### Binary caching tests
if (-not $IsLinux -and -not $IsMacOS) {
    Refresh-TestRoot
    # Test msbuild props and targets
    $CurrentTest = "zlib:x86-windows-static msbuild scripts\testing\integrate-install\..."
    Write-Host $CurrentTest
    ./vcpkg $commonArgs install zlib:x86-windows-static --x-binarysource=clear
    Throw-IfFailed
    foreach ($project in @("VcpkgTriplet", "VcpkgTriplet2", "VcpkgUseStatic", "VcpkgUseStatic2")) {
        $CurrentTest = "msbuild scripts\testing\integrate-install\$project.vcxproj"
        ./vcpkg $commonArgs env "msbuild scripts\testing\integrate-install\$project.vcxproj /p:VcpkgRoot=$TestingRoot /p:IntDir=$TestingRoot\int\ /p:OutDir=$TestingRoot\out\ "
        Throw-IfFailed
        Remove-Item -Recurse -Force $TestingRoot\int
        Remove-Item -Recurse -Force $TestingRoot\out
    }
    $CurrentTest = "zlib:x86-windows msbuild scripts\testing\integrate-install\..."
    Write-Host $CurrentTest
    ./vcpkg $commonArgs install zlib:x86-windows --x-binarysource=clear
    Throw-IfFailed
    foreach ($project in @("Project1", "NoProps")) {
        $CurrentTest = "msbuild scripts\testing\integrate-install\$project.vcxproj"
        Write-Host $CurrentTest
        ./vcpkg $commonArgs env "msbuild scripts\testing\integrate-install\$project.vcxproj /p:VcpkgRoot=$TestingRoot /p:IntDir=$TestingRoot\int\ /p:OutDir=$TestingRoot\out\ "
        Throw-IfFailed
        Remove-Item -Recurse -Force $TestingRoot\int
        Remove-Item -Recurse -Force $TestingRoot\out
    }
}

Refresh-TestRoot

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

# Test that prohibiting backcompat features actually prohibits
$backcompatFeaturePorts = @('vcpkg-uses-test-cmake', 'vcpkg-uses-vcpkg-common-functions')
foreach ($backcompatFeaturePort in $backcompatFeaturePorts) {
    $succeedArgs = $commonArgs + @('install',$backcompatFeaturePort,'--no-binarycaching')
    $failArgs = $succeedArgs + @('--x-prohibit-backcompat-features')
    $CurrentTest = "Should fail: ./vcpkg $($failArgs -join ' ')"
    Write-Host $CurrentTest
    ./vcpkg @failArgs
    if ($LastExitCode -ne 0) {
        Write-Host "... failed (this is good!)"
    } else {
        throw $CurrentTest
    }

    # Install failed when prohibiting backcompat features, so it should succeed if we allow them
    $CurrentTest = "Should succeeed: ./vcpkg $($succeedArgs -join ' ')"
    Write-Host $CurrentTest
    ./vcpkg @succeedArgs
    if ($LastExitCode -ne 0) {
        throw $CurrentTest
    } else {
        Write-Host "... succeeded."
    }
}

# Test export
$CurrentTest = 'Prepare for export test'
Write-Host $CurrentTest
Require-FileNotExists "$TestingRoot/vcpkg-export-output"
Require-FileNotExists "$TestingRoot/vcpkg-export.1.0.0.nupkg"
Require-FileNotExists "$TestingRoot/vcpkg-export-output.zip"
Run-Vcpkg -TestArgs ($commonArgs + @("export", "rapidjson", "tinyxml", "--nuget", "--nuget-id=vcpkg-export", "--nuget-version=1.0.0", "--output=vcpkg-export-output", "--raw", "--zip", "--output-dir=$TestingRoot"))
Require-FileExists "$TestingRoot/vcpkg-export-output"
Require-FileExists "$TestingRoot/vcpkg-export.1.0.0.nupkg"
Require-FileExists "$TestingRoot/vcpkg-export-output.zip"

# Test bad command lines
Run-Vcpkg -TestArgs ($commonArgs + @("install", "zlib", "--vcpkg-rootttttt", "C:\"))
Throw-IfNotFailed

Run-Vcpkg -TestArgs ($commonArgs + @("install", "zlib", "--vcpkg-rootttttt=C:\"))
Throw-IfNotFailed

Run-Vcpkg -TestArgs ($commonArgs + @("install", "zlib", "--fast")) # NB: --fast is not a switch
Throw-IfNotFailed

$LASTEXITCODE = 0
