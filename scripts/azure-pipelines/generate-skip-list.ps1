#! /usr/bin/env pwsh
# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#

<#
.SYNOPSIS
Generates a list of ports to skip in the CI.

.DESCRIPTION
generate-skip-list takes a triplet, and the path to the ci.baseline.txt
file, and generates a skip list string to pass to vcpkg.

.PARAMETER Triplet
The triplet to find skipped ports for.

.PARAMETER BaselineFile
The path to the ci.baseline.txt file.
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory)]
    [string]$Triplet,
    [Parameter(Mandatory)]
    [string]$BaselineFile,
    [switch]$SkipFailures = $false
)

$ErrorActionPreference = 'Stop'

# the triplets for which host = target
$HostTriplets = 'x64-windows','x64-linux','x64-osx'

$baseline = & "${PSScriptRoot}/parse-baseline.ps1" -Triplet $Triplet -BaselineFile $BaselineFile

$skip_list = $baseline.GetEnumerator() | ForEach-Object {
    if ($_.Value -eq 'skip') {
        $_.Name
    } elseif ($_.Value -eq 'fail' -and $SkipFailures) {
        $_.Name
    } elseif ($_.Value -eq 'host' -and $Triplet -notin $HostTriplets) {
        $_.Name
    }
}

$skip_list -join ','
