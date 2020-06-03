# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#

<#
.SYNOPSIS
Deletes files in the indicated archive older than the supplied age.

.PARAMETER Archive
Path to the 'archive' directory from which old archives will be deleted.

.PARAMETER DaysToKeep
Number of days 
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, Position = 0)][string]$Archive,
    [int]$DaysToKeep = 7,
    [int]$Retries = 3
)

if (Test-Path $Archive) {
    $now = Get-Date
    $cutoff = $now.AddDays(-$DaysToKeep)
    for ($thisRetry = 1; $thisRetry -le $Retries; ++$thisRetry) {
        $failedDeletions = @()
        Write-Host "Starting remove-old-archives attempt $thisRetry out of $Retries"
        Write-Host "Deleted the following:"
        Get-ChildItem -Path $Archive -Recurse -File `
        | Where-Object { $_.LastAccessTime -lt $cutoff } `
        | ForEach-Object {
            $fullName = $_.FullName
            Remove-Item -Path $fullName -Force -ErrorAction SilentlyContinue -ErrorVariable thisRemovalFailures
            if ($thisRemovalFailures.Count -eq 0) {
                Write-Host $fullName
            }
            else {
                $failedDeletions += $fullName
            }
        }

        if ($failedDeletions.Count -eq 0) {
            Write-Host "No deletion failures detected, skipping further retries."
            return
        }
        else {
            Write-Host "Failed to delete the following:"
            $failedDeletions | ForEach-Object { Write-Host $_ }
        }
    }
}
else {
    Write-Error "The path $Archive did not exist."
}
