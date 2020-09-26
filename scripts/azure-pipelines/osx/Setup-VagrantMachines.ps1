#!pwsh
#Requires -Version 6.0

<#
.SYNOPSIS
Sets up the configuration for the vagrant virtual machines.

.DESCRIPTION
Setup-VagrantMachines.ps1 sets up the virtual machines for
vcpkg's macOS CI. It puts the VagrantFile and necessary
configuration JSON file into ~/vagrant/vcpkg-eg-mac.

.PARAMETER MachineId
The number to give the machine; should match [0-9]{2}.

.PARAMETER BoxVersion
The version of the box to use.

.PARAMETER AgentPool
The agent pool to add the machine to.

.PARAMETER DevopsUrl
The URL of the ADO instance; for example, https://dev.azure.com/vcpkg is the vcpkg ADO instance.

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
The base name for the vagrant VM; the machine name is $BaseName-$MachineId.
Defaults to 'vcpkg-eg-mac'.

.PARAMETER BoxName
The name of the box to use. Defaults to 'vcpkg/macos-ci',
which is only available internally.

.PARAMETER Force
Delete any existing vagrant/vcpkg-eg-mac directory.

.PARAMETER DiskSize
The size to make the temporary disks in gigabytes. Defaults to 425.

.INPUTS
None

.OUTPUTS
None
#>
[CmdletBinding(PositionalBinding=$False)]
Param(
    [Parameter(Mandatory=$True)]
    [String]$MachineId,

    [Parameter(Mandatory=$True)]
    [String]$BoxVersion,

    [Parameter(Mandatory=$True)]
    [String]$AgentPool,

    [Parameter(Mandatory=$True)]
    [String]$DevopsUrl,

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
    [String]$BoxName = 'vcpkg/macos-ci',

    [Parameter()]
    [Switch]$Force,

    [Parameter()]
    [Int]$DiskSize = 425
)

Set-StrictMode -Version 2

if (-not $IsMacOS) {
    throw 'This script should only be run on a macOS host'
}

if (Test-Path '~/vagrant/vcpkg-eg-mac') {
    if ($Force) {
        Write-Host 'Deleting existing directories'
        Remove-Item -Recurse -Force -Path '~/vagrant/vcpkg-eg-mac' | Out-Null
    } else {
        throw '~/vagrant/vcpkg-eg-mac already exists; try re-running with -Force'
    }
}

Write-Host 'Creating new directories'
if (-not (Test-Path -Path '~/vagrant'))
{
	New-Item -ItemType 'Directory' -Path '~/vagrant' | Out-Null
}
New-Item -ItemType 'Directory' -Path '~/vagrant/vcpkg-eg-mac' | Out-Null

Copy-Item `
    -Path "$PSScriptRoot/configuration/Vagrantfile" `
    -Destination '~/vagrant/vcpkg-eg-mac/Vagrantfile'

$configuration = @{
    pat = $Pat;
    agent_pool = $AgentPool;
    devops_url = $DevopsUrl;
    machine_name = "${BaseName}-${MachineId}";
    box_name = $BoxName;
    box_version = $BoxVersion;
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
