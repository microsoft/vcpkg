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
#>

$Location = 'westus2'
$Prefix = 'PrLin-' + (Get-Date -Format 'yyyy-MM-dd')
$VMSize = 'Standard_D32ds_v4'
$ProtoVMName = 'PROTOTYPE'
$LiveVMPrefix = 'BUILD'
$MakeInstalledDisk = $false
$InstalledDiskSizeInGB = 1024
$ErrorActionPreference = 'Stop'

$ProgressActivity = 'Creating Scale Set'
$TotalProgress = 11
$CurrentProgress = 1

Import-Module "$PSScriptRoot/../create-vmss-helpers.psm1" -DisableNameChecking

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Creating SSH key' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$sshDir = [System.IO.Path]::GetTempPath() + [System.IO.Path]::GetRandomFileName()
mkdir $sshDir
try {
  ssh-keygen.exe -q -b 2048 -t rsa -f "$sshDir/key" -P [string]::Empty
  $sshPublicKey = Get-Content "$sshDir/key.pub"
} finally {
  Remove-Item $sshDir -Recurse -Force
}

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

$allFirewallRules = @()

$allFirewallRules += New-AzNetworkSecurityRuleConfig `
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

$allFirewallRules += New-AzNetworkSecurityRuleConfig `
  -Name AllowSFTP `
  -Description 'Allow (S)FTP' `
  -Access Allow `
  -Protocol Tcp `
  -Direction Outbound `
  -Priority 1009 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange @(21, 22)

$allFirewallRules += New-AzNetworkSecurityRuleConfig `
  -Name AllowDNS `
  -Description 'Allow DNS' `
  -Access Allow `
  -Protocol * `
  -Direction Outbound `
  -Priority 1010 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 53

$allFirewallRules += New-AzNetworkSecurityRuleConfig `
  -Name AllowGit `
  -Description 'Allow git' `
  -Access Allow `
  -Protocol Tcp `
  -Direction Outbound `
  -Priority 1011 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 9418

$allFirewallRules += New-AzNetworkSecurityRuleConfig `
  -Name DenyElse `
  -Description 'Deny everything else' `
  -Access Deny `
  -Protocol * `
  -Direction Outbound `
  -Priority 1013 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange *

$NetworkSecurityGroupName = $ResourceGroupName + 'NetworkSecurity'
$NetworkSecurityGroup = New-AzNetworkSecurityGroup `
  -Name $NetworkSecurityGroupName `
  -ResourceGroupName $ResourceGroupName `
  -Location $Location `
  -SecurityRules $allFirewallRules

$SubnetName = $ResourceGroupName + 'Subnet'
$Subnet = New-AzVirtualNetworkSubnetConfig `
  -Name $SubnetName `
  -AddressPrefix "10.0.0.0/16" `
  -NetworkSecurityGroup $NetworkSecurityGroup `
  -ServiceEndpoint "Microsoft.Storage"

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
  -Kind StorageV2 `
  -MinimumTlsVersion TLS1_2

$StorageAccountKeys = Get-AzStorageAccountKey `
  -ResourceGroupName $ResourceGroupName `
  -Name $StorageAccountName

$StorageAccountKey = $StorageAccountKeys[0].Value

$StorageContext = New-AzStorageContext `
  -StorageAccountName $StorageAccountName `
  -StorageAccountKey $StorageAccountKey

New-AzStorageContainer -Name archives -Context $StorageContext -Permission Off
$StartTime = [DateTime]::Now
$ExpiryTime = $StartTime.AddMonths(6)

$SasToken = New-AzStorageAccountSASToken `
  -Service Blob `
  -Permission "racwdlup" `
  -Context $StorageContext `
  -StartTime $StartTime `
  -ExpiryTime $ExpiryTime `
  -ResourceType Service,Container,Object `
  -Protocol HttpsOnly

$SasToken = $SasToken.Substring(1) # strip leading ?

Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Creating storage account' `
  -CurrentOperation 'Locking down network' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress) # note no ++

# Note that we put the storage account into the firewall after creating the above SAS token or we
# would be denied since the person running this script isn't one of the VMs we're creating here.
Set-AzStorageAccount `
  -ResourceGroupName $ResourceGroupName `
  -AccountName $StorageAccountName `
  -NetworkRuleSet ( `
    @{bypass="AzureServices"; `
    virtualNetworkRules=( `
      @{VirtualNetworkResourceId=$VirtualNetwork.Subnets[0].Id;Action="allow"}); `
    defaultAction="Deny"})

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
  -Linux `
  -ComputerName $ProtoVMName `
  -Credential $Credential `
  -DisablePasswordAuthentication

$VM = Add-AzVMNetworkInterface -VM $VM -Id $Nic.Id
$VM = Set-AzVMSourceImage `
  -VM $VM `
  -PublisherName 'Canonical' `
  -Offer '0001-com-ubuntu-server-focal' `
  -Skus '20_04-lts' `
  -Version latest

$VM = Set-AzVMBootDiagnostic -VM $VM -Disable

$VM = Add-AzVMSshPublicKey `
  -VM $VM `
  -KeyData $sshPublicKey `
  -Path "/home/AdminUser/.ssh/authorized_keys"

New-AzVm `
  -ResourceGroupName $ResourceGroupName `
  -Location $Location `
  -VM $VM

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Running provisioning script provision-image.sh in VM' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$tempScript = [System.IO.Path]::GetTempPath() + [System.IO.Path]::GetRandomFileName() + ".sh"
try {
  $script = Get-Content "$PSScriptRoot\provision-image.sh" -Encoding utf8NoBOM
  $script += "echo `"PROVISIONED_AZURE_STORAGE_NAME=\`"$StorageAccountName\`"`" | sudo tee -a /etc/environment"
  $script += "echo `"PROVISIONED_AZURE_STORAGE_SAS_TOKEN=\`"$SasToken\`"`" | sudo tee -a /etc/environment"
  Set-Content -Path $tempScript -Value $script -Encoding utf8NoBOM

  $ProvisionImageResult = Invoke-AzVMRunCommand `
    -ResourceGroupName $ResourceGroupName `
    -VMName $ProtoVMName `
    -CommandId 'RunShellScript' `
    -ScriptPath $tempScript

  Write-Host "provision-image.sh output: $($ProvisionImageResult.value.Message)"
} finally {
  Remove-Item $tempScript -Recurse -Force
}

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Restarting VM' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

Restart-AzVM -ResourceGroupName $ResourceGroupName -Name $ProtoVMName

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
$ImageName = "$Prefix-BaseImage"
$Image = New-AzImage -Image $ImageConfig -ImageName $ImageName -ResourceGroupName $ResourceGroupName

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

$VmssPublicKey = New-Object -TypeName 'Microsoft.Azure.Management.Compute.Models.SshPublicKey' `
  -ArgumentList @('/home/AdminUser/.ssh/authorized_keys', $sshPublicKey)

if ($MakeInstalledDisk) {
  $Vmss = Set-AzVmssOsProfile `
    -VirtualMachineScaleSet $Vmss `
    -ComputerNamePrefix $LiveVMPrefix `
    -AdminUsername AdminUser `
    -AdminPassword $AdminPW `
    -LinuxConfigurationDisablePasswordAuthentication $true `
    -PublicKey @($VmssPublicKey) `
    -CustomData ([Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("#!/bin/bash`n/etc/provision-disks.sh`n")))
} else {
  $Vmss = Set-AzVmssOsProfile `
    -VirtualMachineScaleSet $Vmss `
    -ComputerNamePrefix $LiveVMPrefix `
    -AdminUsername AdminUser `
    -AdminPassword $AdminPW `
    -LinuxConfigurationDisablePasswordAuthentication $true `
    -PublicKey @($VmssPublicKey)
}

$Vmss = Set-AzVmssStorageProfile `
  -VirtualMachineScaleSet $Vmss `
  -OsDiskCreateOption 'FromImage' `
  -OsDiskCaching ReadOnly `
  -DiffDiskSetting Local `
  -ImageReferenceId $Image.Id

if ($MakeInstalledDisk) {
  $Vmss = Add-AzVmssDataDisk `
    -VirtualMachineScaleSet $Vmss `
    -Lun 0 `
    -Caching 'ReadWrite' `
    -CreateOption Empty `
    -DiskSizeGB $InstalledDiskSizeInGB `
    -StorageAccountType 'StandardSSD_LRS'
}

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
