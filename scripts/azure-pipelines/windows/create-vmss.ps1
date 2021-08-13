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

.PARAMETER CudnnPath
The path to a CUDNN zip file downloaded from NVidia official sources
(e.g. https://developer.nvidia.com/compute/machine-learning/cudnn/secure/8.1.1.33/11.2_20210301/cudnn-11.2-windows-x64-v8.1.1.33.zip
downloaded in a browser with an NVidia account logged in.)
#>

[CmdLetBinding()]
Param(
  [parameter(Mandatory=$true)]
  [string]$CudnnPath
)

$Location = 'westus2'
$Prefix = 'PrWin-'

$Prefix += (Get-Date -Format 'yyyy-MM-dd')
$VMSize = 'Standard_D32ds_v4'
$ProtoVMName = 'PROTOTYPE'
$LiveVMPrefix = 'BUILD'
$WindowsServerSku = '2019-Datacenter'
$MakeInstalledDisk = $false
$InstalledDiskSizeInGB = 1024
$ErrorActionPreference = 'Stop'

$ProgressActivity = 'Creating Scale Set'
$TotalProgress = 20
if ($MakeInstalledDisk) {
  $TotalProgress++
}

$CurrentProgress = 1

Import-Module "$PSScriptRoot/../create-vmss-helpers.psm1" -DisableNameChecking

if (-Not $CudnnPath.EndsWith('.zip')) {
  Write-Error 'Expected CudnnPath to be a zip file.'
  return
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
  -Status 'Creating storage account' `
  -CurrentOperation 'Initial setup' `
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

Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Creating storage account' `
  -CurrentOperation 'Uploading cudnn.zip' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress) # note no ++

New-AzStorageContainer -Name setup -Context $storageContext -Permission blob

Set-AzStorageBlobContent -File $CudnnPath `
  -Container 'setup' `
  -Blob 'cudnn.zip' `
  -Context $StorageContext

$CudnnBlobUrl = "https://$StorageAccountName.blob.core.windows.net/setup/cudnn.zip"

Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Creating storage account' `
  -CurrentOperation 'Creating archives container' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress) # note no ++

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

$InstallDiskName = $ProtoVMName + "InstallDisk"
if ($MakeInstalledDisk) {
  $VM = Add-AzVMDataDisk `
    -Vm $VM `
    -Name $InstallDiskName `
    -Lun 0 `
    -Caching ReadWrite `
    -CreateOption Empty `
    -DiskSizeInGB $InstalledDiskSizeInGB `
    -StorageAccountType 'StandardSSD_LRS'
}

$VM = Set-AzVMBootDiagnostic -VM $VM -Disable
New-AzVm `
  -ResourceGroupName $ResourceGroupName `
  -Location $Location `
  -VM $VM

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Running provisioning script deploy-tlssettings.ps1 in VM' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$ProvisionImageResult = Invoke-AzVMRunCommand `
  -ResourceGroupName $ResourceGroupName `
  -VMName $ProtoVMName `
  -CommandId 'RunPowerShellScript' `
  -ScriptPath "$PSScriptRoot\deploy-tlssettings.ps1"

Write-Host "deploy-tlssettings.ps1 output: $($ProvisionImageResult.value.Message)"
Write-Host 'Waiting 1 minute for VM to reboot...'
Start-Sleep -Seconds 60

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Running provisioning script deploy-psexec.ps1 in VM' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$DeployPsExecResult = Invoke-AzVMRunCommand `
  -ResourceGroupName $ResourceGroupName `
  -VMName $ProtoVMName `
  -CommandId 'RunPowerShellScript' `
  -ScriptPath "$PSScriptRoot\deploy-psexec.ps1"

Write-Host "deploy-psexec.ps1 output: $($DeployPsExecResult.value.Message)"

####################################################################################################
function Invoke-ScriptWithPrefix {
  param(
    [string]$ScriptName,
    [switch]$AddAdminPw,
    [switch]$AddCudnnUrl
  )

  Write-Progress `
    -Activity $ProgressActivity `
    -Status "Running provisioning script $ScriptName in VM" `
    -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

  $DropToAdminUserPrefix = Get-Content "$PSScriptRoot\drop-to-admin-user-prefix.ps1" -Encoding utf8NoBOM -Raw
  $UtilityPrefixContent = Get-Content "$PSScriptRoot\utility-prefix.ps1" -Encoding utf8NoBOM -Raw

  $tempScriptFilename = [System.IO.Path]::GetTempPath() + [System.IO.Path]::GetRandomFileName() + ".txt"
  try {
    $script = Get-Content "$PSScriptRoot\$ScriptName" -Encoding utf8NoBOM -Raw
    if ($AddAdminPw) {
      $script = $script.Replace('# REPLACE WITH DROP-TO-ADMIN-USER-PREFIX.ps1', $DropToAdminUserPrefix)
    }

    if ($AddCudnnUrl) {
      $script = $script.Replace('# REPLACE WITH $CudnnUrl', "`$CudnnUrl = '$CudnnBlobUrl'")
    }

    $script = $script.Replace('# REPLACE WITH UTILITY-PREFIX.ps1', $UtilityPrefixContent);
    Set-Content -Path $tempScriptFilename -Value $script -Encoding utf8NoBOM

    $parameter = $null
    if ($AddAdminPw) {
      $parameter = @{AdminUserPassword = $AdminPW;}
    }

    $InvokeResult = Invoke-AzVMRunCommand `
      -ResourceGroupName $ResourceGroupName `
      -VMName $ProtoVMName `
      -CommandId 'RunPowerShellScript' `
      -ScriptPath $tempScriptFilename `
      -Parameter $parameter

    Write-Host "$ScriptName output: $($InvokeResult.value.Message)"
  } finally {
    Remove-Item $tempScriptFilename -Force
  }
}

Invoke-ScriptWithPrefix -ScriptName 'deploy-windows-sdks.ps1' -AddAdminPw
Restart-AzVM -ResourceGroupName $ResourceGroupName -Name $ProtoVMName

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-visual-studio.ps1' -AddAdminPw
Restart-AzVM -ResourceGroupName $ResourceGroupName -Name $ProtoVMName

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-mpi.ps1' -AddAdminPw
Restart-AzVM -ResourceGroupName $ResourceGroupName -Name $ProtoVMName

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-cuda.ps1' -AddAdminPw -AddCudnnUrl
Restart-AzVM -ResourceGroupName $ResourceGroupName -Name $ProtoVMName

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-inteloneapi.ps1' -AddAdminPw
Restart-AzVM -ResourceGroupName $ResourceGroupName -Name $ProtoVMName

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-pwsh.ps1' -AddAdminPw
Restart-AzVM -ResourceGroupName $ResourceGroupName -Name $ProtoVMName

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Running provisioning script deploy-settings.txt (as a .ps1) in VM' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$ProvisionImageResult = Invoke-AzVMRunCommand `
  -ResourceGroupName $ResourceGroupName `
  -VMName $ProtoVMName `
  -CommandId 'RunPowerShellScript' `
  -ScriptPath "$PSScriptRoot\deploy-settings.txt"

Write-Host "deploy-settings.txt output: $($ProvisionImageResult.value.Message)"

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Deploying SAS token into VM' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$tempScriptFilename = [System.IO.Path]::GetTempPath() + [System.IO.Path]::GetRandomFileName() + ".txt"
try {
  $script = "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' " `
    + "-Name PROVISIONED_AZURE_STORAGE_NAME " `
    + "-Value '$StorageAccountName'`r`n" `
    + "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' " `
    + "-Name PROVISIONED_AZURE_STORAGE_SAS_TOKEN " `
    + "-Value '$SasToken'`r`n"

  Write-Host "Script content is:"
  Write-Host $script

  Set-Content -Path $tempScriptFilename -Value $script -Encoding utf8NoBOM
  $InvokeResult = Invoke-AzVMRunCommand `
    -ResourceGroupName $ResourceGroupName `
    -VMName $ProtoVMName `
    -CommandId 'RunPowerShellScript' `
    -ScriptPath $tempScriptFilename

  Write-Host "Deploy SAS token output: $($InvokeResult.value.Message)"
} finally {
  Remove-Item $tempScriptFilename -Force
}

Restart-AzVM -ResourceGroupName $ResourceGroupName -Name $ProtoVMName

####################################################################################################
if ($MakeInstalledDisk) {
  Invoke-ScriptWithPrefix -ScriptName 'deploy-install-disk.ps1'
  Restart-AzVM -ResourceGroupName $ResourceGroupName -Name $ProtoVMName
}

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Running provisioning script sysprep.ps1 in VM' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$SysprepResult = Invoke-AzVMRunCommand `
  -ResourceGroupName $ResourceGroupName `
  -VMName $ProtoVMName `
  -CommandId 'RunPowerShellScript' `
  -ScriptPath "$PSScriptRoot\sysprep.ps1"

Write-Host "sysprep.ps1 output: $($SysprepResult.value.Message)"

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
$ImageName = "$Prefix-BaseImage"
$Image = New-AzImage -Image $ImageConfig -ImageName $ImageName -ResourceGroupName $ResourceGroupName

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Deleting unused VM and disk' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

Remove-AzVM -Id $VM.ID -Force
Remove-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $PrototypeOSDiskName -Force
if ($MakeInstalledDisk) {
  Remove-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $InstallDiskName -Force
}

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
  -WindowsConfigurationEnableAutomaticUpdate $false

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

####################################################################################################
Write-Progress -Activity $ProgressActivity -Completed
Write-Host "Location: $Location"
Write-Host "Resource group name: $ResourceGroupName"
Write-Host "User name: AdminUser"
Write-Host "Using generated password: $AdminPW"
Write-Host 'Finished!'
