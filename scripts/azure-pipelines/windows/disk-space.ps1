# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#

<#
.SYNOPSIS
Prints total and free disk space for each disk on the system
#>

Function Format-Size {
    [CmdletBinding()]
    Param([long]$Size)

    if ($Size -lt 1024) {
        $Size = [int]$Size
        return "$Size B"
    }

    $Size = $Size / 1024
    if ($Size -lt 1024) {
        $Size = [int]$Size
        return "$Size KiB"
    }

    $Size = $Size / 1024
    if ($Size -lt 1024) {
        $Size = [int]$Size
        return "$Size MiB"
    }

    $Size = [int]($Size / 1024)
    return "$Size GiB"
}

Get-CimInstance -ClassName Win32_LogicalDisk | Format-Table -Property @{Label="Disk"; Expression={ $_.DeviceID }},@{Label="Label"; Expression={ $_.VolumeName }},@{Label="Size"; Expression={ Format-Size($_.Size) }},@{Label="Free Space"; Expression={ Format-Size($_.FreeSpace) }}
