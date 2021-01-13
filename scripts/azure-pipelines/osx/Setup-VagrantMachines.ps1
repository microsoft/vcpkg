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

.PARAMETER DevopsPat
The personal access token which has Read & Manage permissions on the ADO pool.

.PARAMETER Date
The date on which this pool is being created. Sets the default values for BoxVersion and AgentPool.

.PARAMETER BoxVersion
The version of the box to use. If -Date is passed, uses that as the version.

.PARAMETER AgentPool
The agent pool to add the machine to. If -Date is passed, uses "PrOsx-$Date" as the pool.

.PARAMETER DevopsUrl
The URL of the ADO instance; defaults to vcpkg's, which is https://dev.azure.com/vcpkg.

.PARAMETER BaseName
The base name for the vagrant VM; the machine name is $BaseName-$MachineId.
Defaults to 'vcpkg-eg-mac'.

.PARAMETER BoxName
The name of the box to use. Defaults to 'vcpkg/macos-ci',
which is only available internally.

.PARAMETER Force
Delete any existing vagrant/vcpkg-eg-mac directory.

.PARAMETER DiskSize
The size to make the temporary disks in gigabytes. Defaults to 350.

.INPUTS
None

.OUTPUTS
None
#>
[CmdletBinding(PositionalBinding=$False, DefaultParameterSetName='DefineDate')]
Param(
    [Parameter(Mandatory=$True)]
    [String]$MachineId,

    [Parameter(Mandatory=$True)]
    [String]$DevopsPat,

    [Parameter(Mandatory=$True, ParameterSetName='DefineDate')]
    [String]$Date,

    [Parameter(Mandatory=$True, ParameterSetName='DefineVersionAndAgentPool')]
    [String]$BoxVersion,

    [Parameter(Mandatory=$True, ParameterSetName='DefineVersionAndAgentPool')]
    [String]$AgentPool,

    [Parameter(Mandatory=$False)]
    [String]$DevopsUrl = 'https://dev.azure.com/vcpkg',

    [Parameter()]
    [String]$BaseName = 'vcpkg-eg-mac',

    [Parameter()]
    [String]$BoxName = 'vcpkg/macos-ci',

    [Parameter()]
    [Int]$DiskSize = 250,

    [Parameter()]
    [Switch]$Force
)

Set-StrictMode -Version 2

if (-not $IsMacOS) {
    throw 'This script should only be run on a macOS host'
}

if (-not [String]::IsNullOrEmpty($Date)) {
    $BoxVersion = $Date
    $AgentPool = "PrOsx-$Date"
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
if (-not (Test-Path -Path '~/vagrant')) {
	New-Item -ItemType 'Directory' -Path '~/vagrant' | Out-Null
}
New-Item -ItemType 'Directory' -Path '~/vagrant/vcpkg-eg-mac' | Out-Null

Copy-Item `
    -Path "$PSScriptRoot/configuration/Vagrantfile" `
    -Destination '~/vagrant/vcpkg-eg-mac/Vagrantfile'

$configuration = @{
    pat = $DevopsPat;
    agent_pool = $AgentPool;
    devops_url = $DevopsUrl;
    machine_name = "${BaseName}-${MachineId}";
    box_name = $BoxName;
    box_version = $BoxVersion;
    disk_size = $DiskSize;
}
ConvertTo-Json -InputObject $configuration -Depth 5 `
    | Set-Content -Path '~/vagrant/vcpkg-eg-mac/vagrant-configuration.json'
