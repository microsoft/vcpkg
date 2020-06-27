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
    $WorkingRoot
)

$ErrorActionPreference = "Stop"

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

Remove-Item -Recurse -Force $buildtreesRoot -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force $installRoot -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force $packagesRoot -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force $NuGetRoot -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force $NuGetRoot2 -ErrorAction SilentlyContinue
mkdir $NuGetRoot

function Require-File {
    [CmdletBinding()]
    Param(
        $file
    )
    if (-Not (Test-Path $file)) {
        throw "'$CurrentTest' failed to create file '$file'"
    }
}
function Require-Not-File {
    [CmdletBinding()]
    Param(
        $file
    )
    if (Test-Path $file) {
        throw "'$CurrentTest' should not have created file '$file'"
    }
}

# Test simple installation
$CurrentTest = "./vcpkg $($commonArgs -join ' ') install rapidjson --binarycaching --x-binarysource=clear;files,$ArchiveRoot,write;nuget,$NuGetRoot,upload"
Write-Host $CurrentTest
./vcpkg @commonArgs install rapidjson --binarycaching "--x-binarysource=clear;files,$ArchiveRoot,write;nuget,$NuGetRoot,upload"

Require-File "$installRoot/$Triplet/include/rapidjson/rapidjson.h"

# Test simple removal
$CurrentTest = "./vcpkg $($commonArgs -join ' ') remove rapidjson"
Write-Host $CurrentTest
./vcpkg @commonArgs remove rapidjson

Require-Not-File "$installRoot/$Triplet/include/rapidjson/rapidjson.h"

# Test restoring from files archive
$CurrentTest = "./vcpkg $($commonArgs -join ' ') install rapidjson --binarycaching --x-binarysource=clear;files,$ArchiveRoot,read"
Remove-Item -Recurse -Force $installRoot
Remove-Item -Recurse -Force $buildtreesRoot
Write-Host $CurrentTest
./vcpkg @commonArgs install rapidjson --binarycaching "--x-binarysource=clear;files,$ArchiveRoot,read"

Require-File "$installRoot/$Triplet/include/rapidjson/rapidjson.h"
Require-Not-File "$buildtreesRoot/rapidjson/src"

# Test restoring from nuget
$CurrentTest = "./vcpkg $($commonArgs -join ' ') install rapidjson --binarycaching --x-binarysource=clear;nuget,$NuGetRoot"
Remove-Item -Recurse -Force $installRoot
Remove-Item -Recurse -Force $buildtreesRoot
Write-Host $CurrentTest
./vcpkg @commonArgs install rapidjson --binarycaching "--x-binarysource=clear;nuget,$NuGetRoot"

Require-File "$installRoot/$Triplet/include/rapidjson/rapidjson.h"
Require-Not-File "$buildtreesRoot/rapidjson/src"

# Test four-phase flow
$CurrentTest = "./vcpkg $($commonArgs -join ' ') install rapidjson --dry-run --x-write-nuget-packages-config=$TestingRoot/packages.config"
Remove-Item -Recurse -Force $installRoot -ErrorAction SilentlyContinue
Write-Host $CurrentTest
./vcpkg @commonArgs install rapidjson --dry-run "--x-write-nuget-packages-config=$TestingRoot/packages.config"
Require-Not-File "$installRoot/$Triplet/include/rapidjson/rapidjson.h"
Require-Not-File "$buildtreesRoot/rapidjson/src"
Require-File "$TestingRoot/packages.config"

& $(./vcpkg fetch nuget) restore $TestingRoot/packages.config -OutputDirectory "$NuGetRoot2" -Source "$NuGetRoot"

Remove-Item -Recurse -Force $NuGetRoot -ErrorAction SilentlyContinue
mkdir $NuGetRoot

$CurrentTest = "./vcpkg $($commonArgs -join ' ') install rapidjson tinyxml --binarycaching --x-binarysource=clear;nuget,$NuGetRoot2;nuget,$NuGetRoot,upload"
Write-Host $CurrentTest
./vcpkg @commonArgs install rapidjson tinyxml --binarycaching "--x-binarysource=clear;nuget,$NuGetRoot2;nuget,$NuGetRoot,upload"
Require-File "$installRoot/$Triplet/include/rapidjson/rapidjson.h"
Require-File "$installRoot/$Triplet/include/tinyxml.h"
Require-Not-File "$buildtreesRoot/rapidjson/src"
Require-File "$buildtreesRoot/tinyxml/src"

if ($(Get-ChildItem $NuGetRoot/*.nupkg | Measure-Object).count -ne 1) {
    throw "In '$CurrentTest': did not create exactly 1 NuGet package"
}
