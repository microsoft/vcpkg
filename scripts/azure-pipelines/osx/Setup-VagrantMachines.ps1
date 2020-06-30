#!pwsh
#Requires -Version 6.0

<##>
[CmdletBinding(PositionalBinding=$False)]
Param(
    [Parameter(Mandatory=$True)]
    [String]$Pat,

    [Parameter(Mandatory=$True)]
    [String]$ArchivesUsername,

    [Parameter(Mandatory=$True)]
    [String]$ArchivesAccessKey,

    [Parameter(Mandatory=$True)]
    [String]$ArchivesUri,

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
        url = $ArchivesUri;
        share = $ArchivesShare;
    };
}
ConvertTo-Json -InputObject $configuration -Depth 5 `
    | Set-Content -Path '~/vagrant/vcpkg-eg-mac/vagrant-configuration.json'
