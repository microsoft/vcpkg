#!pwsh
#Requires -Version 6.0

<#
.SYNOPSIS
Installs the base box at the specified version from the share.

.PARAMETER StorageAccountAccessKey
An access key for the storage account.

.PARAMETER BaseBoxVersion
The version of the base box to import; this should be a date, i.e. 2020-09-17
#>
[CmdletBinding(PositionalBinding=$False)]
Param(
    [Parameter(Mandatory=$True)]
    [String]$StorageAccountAccessKey,
		[Parameter(Mandatory=$True)]
		[String]$BaseBoxVersion
)

Set-StrictMode -Version 2

if (-not $IsMacOS) {
    throw 'This script should only be run on a macOS host'
}

$encodedAccessKey = [System.Web.HttpUtility]::UrlEncode($StorageAccountAccessKey)

# TODO: finish this, once I have access to a mac again
# mount_smbfs
# vagrant box add
