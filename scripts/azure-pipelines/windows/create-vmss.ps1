# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#

<#
.SYNOPSIS
Creates a Windows virtual machine scale set, set up for vcpkg's CI.

.DESCRIPTION
create-vmss.ps1 creates an Azure Windows VM scale set, set up for vcpkg's CI
system. See https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/overview
for more information.

This script assumes you have installed Azure tools into PowerShell by following the instructions
at https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-3.6.1
or are running from Azure Cloud Shell.

.PARAMETER ImageName
The name of the image to deploy into the scale set.
#>

[CmdLetBinding()]
Param(
  [parameter(Mandatory=$true)]
  [string]$ImageName
)

$Location = 'eastasia'
$Prefix = 'PrWin-'
$Prefix += (Get-Date -Format 'yyyy-MM-dd')
$VMSize = 'Standard_D32a_v4'
$LiveVMPrefix = 'BUILD'
$ErrorActionPreference = 'Stop'

Import-Module "$PSScriptRoot/../create-vmss-helpers.psm1" -DisableNameChecking

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

$Vmss = Set-AzVmssOsProfile `
  -VirtualMachineScaleSet $Vmss `
  -ComputerNamePrefix $LiveVMPrefix `
  -AdminUsername 'AdminUser' `
  -AdminPassword $AdminPW `
  -WindowsConfigurationProvisionVMAgent $true `
  -WindowsConfigurationEnableAutomaticUpdate $false

$Vmss = Set-AzVmssStorageProfile `
  -VirtualMachineScaleSet $Vmss `
  -OsDiskCreateOption 'FromImage' `
  -OsDiskCaching ReadOnly `
  -DiffDiskSetting Local `
  -ImageReferenceId $Image.Id

$Vmss = Set-AzVmssBootDiagnostic `
  -VirtualMachineScaleSet $Vmss `
  -Enabled $true

New-AzVmss `
  -ResourceGroupName $ResourceGroupName `
  -Name $VmssName `
  -VirtualMachineScaleSet $Vmss

Write-Host "Location: $Location"
Write-Host "Resource group name: $ResourceGroupName"
Write-Host 'Finished!'
