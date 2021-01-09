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
The location used as scratch space for testing. A directory named "testing" will be created underneath this location.

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

$WorkingRoot = Resolve-Path $WorkingRoot

$AllTests = Get-ChildItem $PSScriptRoot/end-to-end-tests-dir/*.ps1
if ($Filter -ne $Null) {
    $AllTests = $AllTests | ? { $_.Name -match $Filter }
}
$n = 1
$m = $AllTests.Count

$envvars_clear = @(
    "VCPKG_DEFAULT_HOST_TRIPLET",
    "VCPKG_DEFAULT_TRIPLET",
    "VCPKG_BINARY_SOURCES",
    "VCPKG_OVERLAY_PORTS",
    "VCPKG_OVERLAY_TRIPLETS",
    "VCPKG_KEEP_ENV_VARS",
    "VCPKG_ROOT",
    "VCPKG_FEATURE_FLAGS",
    "VCPKG_DISABLE_METRICS"
)
$envvars = $envvars_clear + @("VCPKG_DOWNLOADS")

$AllTests | % {
    Write-Host "[end-to-end-tests.ps1] [$n/$m] Running suite $_"

    $envbackup = @{}
    foreach ($var in $envvars)
    {
        $envbackup[$var] = [System.Environment]::GetEnvironmentVariable($var)
    }

    try
    {
        foreach ($var in $envvars_clear)
        {
            [System.Environment]::SetEnvironmentVariable($var, $null)
        }
        & $_
    }
    finally
    {
        foreach ($var in $envvars)
        {
            [System.Environment]::SetEnvironmentVariable($var, $envbackup[$var])
        }
    }
    $n += 1
}

$LASTEXITCODE = 0
