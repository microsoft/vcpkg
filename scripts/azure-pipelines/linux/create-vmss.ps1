# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#

<#
.SYNOPSIS
Creates a Linux virtual machine scale set, set up for vcpkg's CI.

.DESCRIPTION
create-vmss.ps1 creates an Azure Linux VM scale set, set up for vcpkg's CI
system. See https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/overview
for more information.

This script assumes you have installed Azure tools into PowerShell by following the instructions
at https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-3.6.1
or are running from Azure Cloud Shell.

This script assumes you have installed the OpenSSH Client optional Windows component.


.PARAMETER ImageName
The name of the image to deploy into the scale set.
#>

[CmdLetBinding()]
Param(
  [parameter(Mandatory=$true)]
  [string]$ImageName
)

$Location = 'westus2'
$Prefix = 'PrLin-'
$Prefix += (Get-Date -Format 'yyyy-MM-dd')
$VMSize = 'Standard_D32a_v4'
$LiveVMPrefix = 'BUILD'
$ErrorActionPreference = 'Stop'

Import-Module "$PSScriptRoot/../create-vmss-helpers.psm1" -DisableNameChecking

$sshDir = [System.IO.Path]::GetTempPath() + [System.IO.Path]::GetRandomFileName()
mkdir $sshDir
try {
  ssh-keygen.exe -q -b 2048 -t rsa -f "$sshDir/key" -P [string]::Empty
  $sshPublicKey = Get-Content "$sshDir/key.pub"
} finally {
  Remove-Item $sshDir -Recurse -Force
}
$ResourceGroupName = Find-ResourceGroupName $Prefix
$AdminPW = New-Password
$Image = Get-AzImage -ResourceGroupName 'vcpkg-image-minting' -ImageName $ImageName

New-AzResourceGroup -Name $ResourceGroupName -Location $Location

$VirtualNetwork = Create-LockedDownNetwork -ResourceGroupName $ResourceGroupName -Location $Location
$VmssIpConfigName = $ResourceGroupName + 'VmssIpConfig'
$VmssIpConfig = New-AzVmssIpConfig -SubnetId $VirtualNetwork.Subnets[0].Id -Primary -Name $VmssIpConfigName
$VmssName = $ResourceGroupName + 'Vmss'
$Vmss = New-AzVmssConfig `
  -Location $Location `
  -SkuCapacity 0 `
  -SkuName $VMSize `
  -SkuTier 'Standard' `
  -Overprovision $false `
  -UpgradePolicyMode Manual `
  -EvictionPolicy Delete `
  -Priority Spot `
  -MaxPrice -1

$NicName = $ResourceGroupName + 'NIC'
New-AzNetworkInterface `
  -Name $NicName `
  -ResourceGroupName $ResourceGroupName `
  -Location $Location `
  -Subnet $VirtualNetwork.Subnets[0]

$Vmss = Add-AzVmssNetworkInterfaceConfiguration `
  -VirtualMachineScaleSet $Vmss `
  -Primary $true `
  -IpConfiguration $VmssIpConfig `
  -NetworkSecurityGroupId $VirtualNetwork.Subnets[0].NetworkSecurityGroup.Id `
  -Name $NicName

$VmssPublicKey = New-Object -TypeName 'Microsoft.Azure.Management.Compute.Models.SshPublicKey' `
  -ArgumentList @('/home/AdminUser/.ssh/authorized_keys', $sshPublicKey)

$Vmss = Set-AzVmssOsProfile `
  -VirtualMachineScaleSet $Vmss `
  -ComputerNamePrefix $LiveVMPrefix `
  -AdminUsername AdminUser `
  -AdminPassword $AdminPW `
  -LinuxConfigurationDisablePasswordAuthentication $true `
  -PublicKey @($VmssPublicKey)

$Vmss = Set-AzVmssStorageProfile `
  -VirtualMachineScaleSet $Vmss `
  -OsDiskCreateOption 'FromImage' `
  -OsDiskCaching ReadOnly `
  -DiffDiskSetting Local `
  -ImageReferenceId $Image.Id

New-AzVmss `
  -ResourceGroupName $ResourceGroupName `
  -Name $VmssName `
  -VirtualMachineScaleSet $Vmss

Write-Host "Location: $Location"
Write-Host "Resource group name: $ResourceGroupName"
Write-Host 'Finished!'
