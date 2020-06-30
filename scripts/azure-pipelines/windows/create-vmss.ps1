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
#>

$Location = 'westus2'
$Prefix = 'PrWin-' + (Get-Date -Format 'yyyy-MM-dd')
$VMSize = 'Standard_D16a_v4'
$ProtoVMName = 'PROTOTYPE'
$LiveVMPrefix = 'BUILD'
$WindowsServerSku = '2019-Datacenter'
$ErrorActionPreference = 'Stop'

$ProgressActivity = 'Creating Scale Set'
$TotalProgress = 12
$CurrentProgress = 1

Import-Module "$PSScriptRoot/../create-vmss-helpers.psm1" -DisableNameChecking

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Creating resource group' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$ResourceGroupName = Find-ResourceGroupName $Prefix
$AdminPW = New-Password
New-AzResourceGroup -Name $ResourceGroupName -Location $Location
$AdminPWSecure = ConvertTo-SecureString $AdminPW -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ("AdminUser", $AdminPWSecure)

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Creating virtual network' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$allowHttp = New-AzNetworkSecurityRuleConfig `
  -Name AllowHTTP `
  -Description 'Allow HTTP(S)' `
  -Access Allow `
  -Protocol Tcp `
  -Direction Outbound `
  -Priority 1008 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange @(80, 443)

$allowDns = New-AzNetworkSecurityRuleConfig `
  -Name AllowDNS `
  -Description 'Allow DNS' `
  -Access Allow `
  -Protocol * `
  -Direction Outbound `
  -Priority 1009 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 53

$allowGit = New-AzNetworkSecurityRuleConfig `
  -Name AllowGit `
  -Description 'Allow git' `
  -Access Allow `
  -Protocol Tcp `
  -Direction Outbound `
  -Priority 1010 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 9418

$allowStorage = New-AzNetworkSecurityRuleConfig `
  -Name AllowStorage `
  -Description 'Allow Storage' `
  -Access Allow `
  -Protocol * `
  -Direction Outbound `
  -Priority 1011 `
  -SourceAddressPrefix VirtualNetwork `
  -SourcePortRange * `
  -DestinationAddressPrefix Storage `
  -DestinationPortRange *

$denyEverythingElse = New-AzNetworkSecurityRuleConfig `
  -Name DenyElse `
  -Description 'Deny everything else' `
  -Access Deny `
  -Protocol * `
  -Direction Outbound `
  -Priority 1012 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange *

$NetworkSecurityGroupName = $ResourceGroupName + 'NetworkSecurity'
$NetworkSecurityGroup = New-AzNetworkSecurityGroup `
  -Name $NetworkSecurityGroupName `
  -ResourceGroupName $ResourceGroupName `
  -Location $Location `
  -SecurityRules @($allowHttp, $allowDns, $allowGit, $allowStorage, $denyEverythingElse)

$SubnetName = $ResourceGroupName + 'Subnet'
$Subnet = New-AzVirtualNetworkSubnetConfig `
  -Name $SubnetName `
  -AddressPrefix "10.0.0.0/16" `
  -NetworkSecurityGroup $NetworkSecurityGroup

$VirtualNetworkName = $ResourceGroupName + 'Network'
$VirtualNetwork = New-AzVirtualNetwork `
  -Name $VirtualNetworkName `
  -ResourceGroupName $ResourceGroupName `
  -Location $Location `
  -AddressPrefix "10.0.0.0/16" `
  -Subnet $Subnet

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Creating archives storage account' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$StorageAccountName = Sanitize-Name $ResourceGroupName

New-AzStorageAccount `
  -ResourceGroupName $ResourceGroupName `
  -Location $Location `
  -Name $StorageAccountName `
  -SkuName 'Standard_LRS' `
  -Kind StorageV2

$StorageAccountKeys = Get-AzStorageAccountKey `
  -ResourceGroupName $ResourceGroupName `
  -Name $StorageAccountName

$StorageAccountKey = $StorageAccountKeys[0].Value

$StorageContext = New-AzStorageContext `
  -StorageAccountName $StorageAccountName `
  -StorageAccountKey $StorageAccountKey

New-AzStorageShare -Name 'archives' -Context $StorageContext
Set-AzStorageShareQuota -ShareName 'archives' -Context $StorageContext -Quota 2048

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Creating prototype VM' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$NicName = $ResourceGroupName + 'NIC'
$Nic = New-AzNetworkInterface `
  -Name $NicName `
  -ResourceGroupName $ResourceGroupName `
  -Location $Location `
  -Subnet $VirtualNetwork.Subnets[0]

$VM = New-AzVMConfig -Name $ProtoVMName -VMSize $VMSize -Priority 'Spot' -MaxPrice -1
$VM = Set-AzVMOperatingSystem `
  -VM $VM `
  -Windows `
  -ComputerName $ProtoVMName `
  -Credential $Credential `
  -ProvisionVMAgent

$VM = Add-AzVMNetworkInterface -VM $VM -Id $Nic.Id
$VM = Set-AzVMSourceImage `
  -VM $VM `
  -PublisherName 'MicrosoftWindowsServer' `
  -Offer 'WindowsServer' `
  -Skus $WindowsServerSku `
  -Version latest

$VM = Set-AzVMBootDiagnostic -VM $VM -Disable
New-AzVm `
  -ResourceGroupName $ResourceGroupName `
  -Location $Location `
  -VM $VM

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Running provisioning script provision-image.txt (as a .ps1) in VM' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

Invoke-AzVMRunCommand `
  -ResourceGroupName $ResourceGroupName `
  -VMName $ProtoVMName `
  -CommandId 'RunPowerShellScript' `
  -ScriptPath "$PSScriptRoot\provision-image.txt" `
  -Parameter @{AdminUserPassword = $AdminPW; `
    StorageAccountName=$StorageAccountName; `
    StorageAccountKey=$StorageAccountKey;}

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Restarting VM' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

Restart-AzVM -ResourceGroupName $ResourceGroupName -Name $ProtoVMName

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Running provisioning script sysprep.ps1 in VM' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

Invoke-AzVMRunCommand `
  -ResourceGroupName $ResourceGroupName `
  -VMName $ProtoVMName `
  -CommandId 'RunPowerShellScript' `
  -ScriptPath "$PSScriptRoot\sysprep.ps1"

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Waiting for VM to shut down' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

Wait-Shutdown -ResourceGroupName $ResourceGroupName -Name $ProtoVMName

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Converting VM to Image' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

Stop-AzVM `
  -ResourceGroupName $ResourceGroupName `
  -Name $ProtoVMName `
  -Force

Set-AzVM `
  -ResourceGroupName $ResourceGroupName `
  -Name $ProtoVMName `
  -Generalized

$VM = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $ProtoVMName
$PrototypeOSDiskName = $VM.StorageProfile.OsDisk.Name
$ImageConfig = New-AzImageConfig -Location $Location -SourceVirtualMachineId $VM.ID
$Image = New-AzImage -Image $ImageConfig -ImageName $ProtoVMName -ResourceGroupName $ResourceGroupName

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Deleting unused VM and disk' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

Remove-AzVM -Id $VM.ID -Force
Remove-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $PrototypeOSDiskName -Force

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Creating scale set' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$VmssIpConfigName = $ResourceGroupName + 'VmssIpConfig'
$VmssIpConfig = New-AzVmssIpConfig -SubnetId $Nic.IpConfigurations[0].Subnet.Id -Primary -Name $VmssIpConfigName
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

$Vmss = Add-AzVmssNetworkInterfaceConfiguration `
  -VirtualMachineScaleSet $Vmss `
  -Primary $true `
  -IpConfiguration $VmssIpConfig `
  -NetworkSecurityGroupId $NetworkSecurityGroup.Id `
  -Name $NicName

$Vmss = Set-AzVmssOsProfile `
  -VirtualMachineScaleSet $Vmss `
  -ComputerNamePrefix $LiveVMPrefix `
  -AdminUsername 'AdminUser' `
  -AdminPassword $AdminPW `
  -WindowsConfigurationProvisionVMAgent $true `
  -WindowsConfigurationEnableAutomaticUpdate $true

$Vmss = Set-AzVmssStorageProfile `
  -VirtualMachineScaleSet $Vmss `
  -OsDiskCreateOption 'FromImage' `
  -OsDiskCaching ReadWrite `
  -ImageReferenceId $Image.Id

New-AzVmss `
  -ResourceGroupName $ResourceGroupName `
  -Name $VmssName `
  -VirtualMachineScaleSet $Vmss

####################################################################################################
Write-Progress -Activity $ProgressActivity -Completed
Write-Host "Location: $Location"
Write-Host "Resource group name: $ResourceGroupName"
Write-Host "User name: AdminUser"
Write-Host "Using generated password: $AdminPW"
Write-Host 'Finished!'
