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
    [string]$Triplet,
    [string]$BaselineFile,
    [switch]$SkipFailures = $false,
    [String[]]$AdditionalSkips = @()
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -Path $BaselineFile)) {
    Write-Error "Unable to find baseline file $BaselineFile"
    throw
}

#read in the file, strip out comments and blank lines and spaces
$baselineListRaw = Get-Content -Path $BaselineFile `
    | Where-Object { -not ($_ -match "\s*#") } `
    | Where-Object { -not ( $_ -match "^\s*$") } `
    | ForEach-Object { $_ -replace "\s" }

###############################################################
# This script is running at the beginning of the CI test, so do a little extra
# checking so things can fail early.

#verify everything has a valid value
$missingValues = $baselineListRaw | Where-Object { -not ($_ -match "=\w") }

if ($missingValues) {
    Write-Error "The following are missing values: $missingValues"
    throw
}

$invalidValues = $baselineListRaw `
    | Where-Object { -not ($_ -match "=(skip|pass|fail|ignore)$") }

if ($invalidValues) {
    Write-Error "The following have invalid values: $invalidValues"
    throw
}

$baselineForTriplet = $baselineListRaw `
    | Where-Object { $_ -match ":$Triplet=" }

# Verify there are no duplicates (redefinitions are not allowed)
$file_map = @{ }
foreach ($port in $baselineForTriplet | ForEach-Object { $_ -replace ":.*$" }) {
    if ($null -ne $file_map[$port]) {
        Write-Error `
            "$($port):$($Triplet) has multiple definitions in $baselineFile"
        throw
    }
    $file_map[$port] = $true
}

# Format the skip list for the command line
if ($SkipFailures) {
    $targetRegex = "=(?:skip|fail)$"
} else {
    $targetRegex = "=skip$"
}

$skip_list = $baselineForTriplet `
    | Where-Object { $_ -match $targetRegex } `
    | ForEach-Object { $_ -replace ":.*$" }
$skip_list += $AdditionalSkips
[string]::Join(",", $skip_list)
