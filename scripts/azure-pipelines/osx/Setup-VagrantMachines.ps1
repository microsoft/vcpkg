#!pwsh
#Requires -Version 6.0

<#
.SYNOPSIS
Sets up the configuration for the vagrant virtual machines.

.DESCRIPTION
Setup-VagrantMachines.ps1 sets up the virtual machines for
vcpkg's macOS CI. It puts the VagrantFile and necessary
configuration JSON file into ~/vagrant/vcpkg-eg-mac.

.PARAMETER Pat
The personal access token which has Read & Manage permissions on the ADO pool.

.PARAMETER ArchivesUsername
The username for the archives share.

.PARAMETER ArchivesAccessKey
The access key for the archives share.

.PARAMETER ArchivesUrn
The URN of the archives share; looks like `foo.windows.core.net`.

.PARAMETER ArchivesShare
The archives share name.

.PARAMETER BaseName
The base name for the vagrant VM; the machine name is $BaseName-$MachineIdentifiers.
Defaults to 'vcpkg-eg-mac'.

.PARAMETER Force
Delete any existing vagrant/vcpkg-eg-mac directory.

.PARAMETER DiskSize
The size to make the temporary disks in gigabytes. Defaults to 425.

.PARAMETER MachineIdentifiers
The numbers to give the machines; should match [0-9]{2}.

.INPUTS
None

.OUTPUTS
None
#>
[CmdletBinding(PositionalBinding=$False)]
Param(
    [Parameter(Mandatory=$True)]
    [String]$Pat,

    [Parameter(Mandatory=$True)]
    [String]$ArchivesUsername,

    [Parameter(Mandatory=$True)]
    [String]$ArchivesAccessKey,

    [Parameter(Mandatory=$True)]
    [String]$ArchivesUrn,

    [Parameter(Mandatory=$True)]
    [String]$ArchivesShare,

    [Parameter()]
    [String]$BaseName = 'vcpkg-eg-mac',

    [Parameter()]
    [Switch]$Force,

    [Parameter()]
    [Int]$DiskSize = 425,

    [Parameter(Mandatory=$True, ValueFromRemainingArguments)]
    [String[]]$MachineIdentifiers
)

Set-StrictMode -Version 2

if (-not $IsMacOS) {
    throw 'This script should only be run on a macOS host'
}

if (Test-Path '~/vagrant') {
    if ($Force) {
        Write-Host 'Deleting existing directories'
        Remove-Item -Recurse -Force -Path '~/vagrant' | Out-Null
    } else {
        throw '~/vagrant already exists; try re-running with -Force'
    }
}

Write-Host 'Creating new directories'
New-Item -ItemType 'Directory' -Path '~/vagrant' | Out-Null
New-Item -ItemType 'Directory' -Path '~/vagrant/vcpkg-eg-mac' | Out-Null

Copy-Item `
    -Path "$PSScriptRoot/configuration/VagrantFile" `
    -Destination '~/vagrant/vcpkg-eg-mac/VagrantFile'

$configuration = @{
    pat = $Pat;
    base_name = $BaseName;
    machine_identifiers = $MachineIdentifiers;
    disk_size = $DiskSize;
    archives = @{
        username = $ArchivesUsername;
        access_key = $ArchivesAccessKey;
        urn = $ArchivesUrn;
        share = $ArchivesShare;
    };
}
ConvertTo-Json -InputObject $configuration -Depth 5 `
    | Set-Content -Path '~/vagrant/vcpkg-eg-mac/vagrant-configuration.json'
