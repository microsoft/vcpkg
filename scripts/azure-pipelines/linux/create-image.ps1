# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#

<#
.SYNOPSIS
Creates a Linux virtual machine image, set up for vcpkg's CI.

.DESCRIPTION
create-image.ps1 creates an Azure Linux VM image, set up for vcpkg's CI system.
This script assumes you have installed Azure tools into PowerShell by following the instructions
at https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-3.6.1
or are running from Azure Cloud Shell.

This script assumes you have installed the OpenSSH Client optional Windows component.
#>

$Location = 'westus2'
$Prefix = 'Lin-'
$Prefix += (Get-Date -Format 'yyyy-MM-dd')
$VMSize = 'Standard_D32as_v4'
$ProtoVMName = 'PROTOTYPE'
$ErrorActionPreference = 'Stop'

$ProgressActivity = 'Creating Linux Image'
$TotalProgress = 9
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

$VirtualNetwork = Create-LockedDownNetwork -ResourceGroupName $ResourceGroupName -Location $Location

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
  -Skus '20_04-lts-gen2' `
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

$ProvisionImageResult = Invoke-AzVMRunCommandWithRetries `
  -ResourceGroupName $ResourceGroupName `
  -VMName $ProtoVMName `
  -CommandId 'RunShellScript' `
  -ScriptPath "$PSScriptRoot\provision-image.sh"

Write-Host "provision-image.sh output: $($ProvisionImageResult.value.Message)"

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
$ImageConfig = New-AzImageConfig -Location $Location -SourceVirtualMachineId $VM.ID -HyperVGeneration 'V2'
$ImageName = Find-ImageName -ResourceGroupName 'vcpkg-image-minting' -Prefix $Prefix
New-AzImage -Image $ImageConfig -ImageName $ImageName -ResourceGroupName 'vcpkg-image-minting'

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Deleting unused temporary resources' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

Remove-AzResourceGroup $ResourceGroupName -Force

####################################################################################################
Write-Progress -Activity $ProgressActivity -Completed
Write-Host "Generated Image:  $ImageName"
Write-Host 'Finished!'
