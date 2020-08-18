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
    "--x-packages-root=$packagesRoot"
)

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

if (-not $IsLinux -and -not $IsMacOS)
{
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
$args = $commonArgs + @("install","rapidjson","--binarycaching","--x-binarysource=clear;files,$ArchiveRoot,write;nuget,$NuGetRoot,readwrite")
$CurrentTest = "./vcpkg $($args -join ' ')"
Write-Host $CurrentTest
./vcpkg @args
Throw-IfFailed

Require-FileExists "$installRoot/$Triplet/include/rapidjson/rapidjson.h"

# Test simple removal
$args = $commonArgs + @("remove", "rapidjson")
$CurrentTest = "./vcpkg $($args -join ' ')"
Write-Host $CurrentTest
./vcpkg @args
Throw-IfFailed

Require-FileNotExists "$installRoot/$Triplet/include/rapidjson/rapidjson.h"

# Test restoring from files archive
$args = $commonArgs + @("install","rapidjson","--binarycaching","--x-binarysource=clear;files,$ArchiveRoot,read")
$CurrentTest = "./vcpkg $($args -join ' ')"
Remove-Item -Recurse -Force $installRoot
Remove-Item -Recurse -Force $buildtreesRoot
Write-Host $CurrentTest
./vcpkg @args
Throw-IfFailed

Require-FileExists "$installRoot/$Triplet/include/rapidjson/rapidjson.h"
Require-FileNotExists "$buildtreesRoot/rapidjson/src"

# Test restoring from nuget
$args = $commonArgs + @("install","rapidjson","--binarycaching","--x-binarysource=clear;nuget,$NuGetRoot")
$CurrentTest = "./vcpkg $($args -join ' ')"
Remove-Item -Recurse -Force $installRoot
Remove-Item -Recurse -Force $buildtreesRoot
Write-Host $CurrentTest
./vcpkg @args
Throw-IfFailed

Require-FileExists "$installRoot/$Triplet/include/rapidjson/rapidjson.h"
Require-FileNotExists "$buildtreesRoot/rapidjson/src"

# Test four-phase flow
$args = $commonArgs + @("install","rapidjson","--dry-run","--x-write-nuget-packages-config=$TestingRoot/packages.config")
$CurrentTest = "./vcpkg $($args -join ' ')"
Remove-Item -Recurse -Force $installRoot -ErrorAction SilentlyContinue
Write-Host $CurrentTest
./vcpkg @args
Throw-IfFailed
Require-FileNotExists "$installRoot/$Triplet/include/rapidjson/rapidjson.h"
Require-FileNotExists "$buildtreesRoot/rapidjson/src"
Require-FileExists "$TestingRoot/packages.config"

& $(./vcpkg fetch nuget) restore $TestingRoot/packages.config -OutputDirectory "$NuGetRoot2" -Source "$NuGetRoot"
Throw-IfFailed

Remove-Item -Recurse -Force $NuGetRoot -ErrorAction SilentlyContinue
mkdir $NuGetRoot

$args = $commonArgs + @("install","rapidjson","tinyxml","--binarycaching","--x-binarysource=clear;nuget,$NuGetRoot2;nuget,$NuGetRoot,write")
$CurrentTest = "./vcpkg $($args -join ' ')"
Write-Host $CurrentTest
./vcpkg @args
Throw-IfFailed
Require-FileExists "$installRoot/$Triplet/include/rapidjson/rapidjson.h"
Require-FileExists "$installRoot/$Triplet/include/tinyxml.h"
Require-FileNotExists "$buildtreesRoot/rapidjson/src"
Require-FileExists "$buildtreesRoot/tinyxml/src"

if ((Get-ChildItem $NuGetRoot -Filter '*.nupkg' | Measure-Object).Count -ne 1) {
    throw "In '$CurrentTest': did not create exactly 1 NuGet package"
}
