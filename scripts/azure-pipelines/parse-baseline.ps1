#! /usr/bin/env pwsh
# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#

<#
.SYNOPSIS
Parses the ci.baseline.txt file.

.DESCRIPTION
parse-baseline takes a triplet, and the path to the ci.baseline.txt file,
and returns a map from port name to one of the following strings:

* 'host' - This port should pass for triplets where HOST_TRIPLET == TARGET_TRIPLET
* 'skip' - This port should be skipped for this triplet
* 'fail' - This port should fail for this triplet
* 'pass' - This port should pass for this triplet. Equivalent to the port not being in the map.

.PARAMETER Triplet
The triplet to find port kind for.

.PARAMETER BaselineFile
The path to the ci.baseline.txt file.
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory)]
    [string]$Triplet,
    [Parameter(Mandatory)]
    [string]$BaselineFile
)

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
    | Where-Object { -not ($_ -match "=(skip|pass|fail|host)$") }

if ($invalidValues) {
    Write-Error "The following have invalid values: $invalidValues"
    throw
}

$hostPortsWithTriplet = $baselineListRaw `
    | Where-Object { $_ -match ":.*=host$" }

if ($hostPortsWithTriplet) {
    Write-Error "The following host ports have triplets: $hostPortsWithTriplet"
    throw
}

# do the actual parsing

$actualBaseline = $baselineListRaw | ForEach-Object {
    if ($_ -match "^(.*):$Triplet=(.*)$") {
        @{
            port = $matches[1]
            kind = $matches[2]
        }
    } elseif ($_ -match "^(.*)=host$") {
        @{
            port = $matches[1]
            kind = 'host'
        }
    }
}
$result = @{}
$actualBaseline | ForEach-Object {
    $port = $_.port
    $kind = $_.kind
    switch -regex ($kind) {
        '^host$' {
            if ($port -notin $result) {
                $result[$port] = 'host'
            } elseif ($result[$port] -eq 'host') {
                Write-Error `
                    "${port}=host has multiple definitions in $baselineFile"
                throw
            }
        }
        '^(skip|pass|fail)$' {
            if ($port -notin $result -or $result[$port] -eq 'host') {
                $result[$port] = $kind
            } else {
                Write-Error `
                    "${port}:${Triplet} has multiple definitions in $baselineFile"
                throw
            }
        }
    }
}

$result
