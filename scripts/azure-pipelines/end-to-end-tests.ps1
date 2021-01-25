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
    [string]$WorkingRoot,
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$Filter
)

$ErrorActionPreference = "Stop"

if (-Not (Test-Path $WorkingRoot)) {
    New-Item -Path $WorkingRoot -ItemType Directory
}

$WorkingRoot = (Get-Item $WorkingRoot).FullName

$AllTests = Get-ChildItem $PSScriptRoot/end-to-end-tests-dir/*.ps1
if ($Filter -ne $Null) {
    $AllTests = $AllTests | ? { $_.Name -match $Filter }
}
$n = 1
$m = $AllTests.Count

$AllTests | % {
    Write-Host "[end-to-end-tests.ps1] [$n/$m] Running suite $_"
    & $_
    $n += 1
}

Write-Host "[end-to-end-tests.ps1] All tests passed."
$LASTEXITCODE = 0
