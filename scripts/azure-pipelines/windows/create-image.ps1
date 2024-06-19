# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#

<#
.SYNOPSIS
Creates a Windows virtual machine image, set up for vcpkg's CI.

.DESCRIPTION
create-image.ps1 creates an Azure Windows VM image, set up for vcpkg's CI system.

This script assumes you have installed Azure tools into PowerShell by following the instructions
at https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-3.6.1
or are running from Azure Cloud Shell.
#>

$Location = 'westus3'
$DatePrefixComponent = Get-Date -Format 'yyyy-MM-dd'
$Prefix = "Win-$DatePrefixComponent"
$GalleryImageVersion = $DatePrefixComponent.Replace('-','.')
$VMSize = 'Standard_D8ads_v5'
$ProtoVMName = 'PROTOTYPE'
$WindowsServerSku = '2022-datacenter-azure-edition'
$ErrorActionPreference = 'Stop'

$ProgressActivity = 'Creating Windows Image'
$TotalProgress = 18
$CurrentProgress = 1

# Assigning this to another variable helps when running the commands in this script manually for
# debugging
$Root = $PSScriptRoot

Import-Module "$Root/../create-vmss-helpers.psm1" -DisableNameChecking -Force

$AdminPW = New-Password
$AdminPWSecure = ConvertTo-SecureString $AdminPW -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ("AdminUser", $AdminPWSecure)

$VirtualNetwork = Get-AzVirtualNetwork -ResourceGroupName 'vcpkg-image-minting' -Name 'vcpkg-image-mintingNetwork'

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Creating prototype VM' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$NicName = $Prefix + 'NIC'
$Nic = New-AzNetworkInterface `
  -Name $NicName `
  -ResourceGroupName 'vcpkg-image-minting' `
  -Location $Location `
  -Subnet $VirtualNetwork.Subnets[0] `
  -EnableAcceleratedNetworking

$VM = New-AzVMConfig -Name $ProtoVMName -VMSize $VMSize -SecurityType TrustedLaunch -IdentityType SystemAssigned
$VM = Set-AzVMOperatingSystem `
  -VM $VM `
  -Windows `
  -ComputerName $ProtoVMName `
  -Credential $Credential `
  -ProvisionVMAgent

$VM = Add-AzVMNetworkInterface -VM $VM -Id $Nic.Id
$VM = Set-AzVMOSDisk -VM $VM -StorageAccountType 'Premium_LRS' -CreateOption 'FromImage'
$VM = Set-AzVMSourceImage `
  -VM $VM `
  -PublisherName 'MicrosoftWindowsServer' `
  -Offer 'WindowsServer' `
  -Skus $WindowsServerSku `
  -Version latest

$VM = Set-AzVMBootDiagnostic -VM $VM -Disable
New-AzVm `
  -ResourceGroupName 'vcpkg-image-minting' `
  -Location $Location `
  -VM $VM

$VMCreated = Get-AzVM -ResourceGroupName 'vcpkg-image-minting' -Name $ProtoVMName
$VMCreatedOsDisk = $VMCreated.StorageProfile.OsDisk.Name

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Granting permissions to use vcpkg-image-minting storage account' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$VcpkgImageMintingAccount = Get-AzStorageAccount -ResourceGroupName 'vcpkg-image-minting' -Name 'vcpkgimageminting'

$CudnnStorageContext = New-AzStorageContext -StorageAccountName 'vcpkgimageminting' -UseConnectedAccount
$StartTime = Get-Date
$ExpiryTime = $StartTime.AddDays(1)
$CudnnSas = New-AzStorageContainerSASToken -Name 'assets' -Permission r -StartTime $StartTime -ExpiryTime $ExpiryTime -Context $CudnnStorageContext
$CudnnUrl = "https://vcpkgimageminting.blob.core.windows.net/assets/cudnn-windows-x86_64-8.8.1.3_cuda12-archive.zip?$CudnnSas"

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Running provisioning script deploy-tlssettings.ps1 in VM' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$ProvisionImageResult = Invoke-AzVMRunCommandWithRetries `
  -ResourceGroupName 'vcpkg-image-minting' `
  -VMName $ProtoVMName `
  -CommandId 'RunPowerShellScript' `
  -ScriptPath "$Root\deploy-tlssettings.ps1"

Write-Host "deploy-tlssettings.ps1 output: $($ProvisionImageResult.value.Message)"
Write-Host 'Waiting 1 minute for VM to reboot...'
Start-Sleep -Seconds 60

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Running provisioning script deploy-psexec.ps1 in VM' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$DeployPsExecResult = Invoke-AzVMRunCommandWithRetries `
  -ResourceGroupName 'vcpkg-image-minting' `
  -VMName $ProtoVMName `
  -CommandId 'RunPowerShellScript' `
  -ScriptPath "$Root\deploy-psexec.ps1"

Write-Host "deploy-psexec.ps1 output: $($DeployPsExecResult.value.Message)"

####################################################################################################
function Invoke-ScriptWithPrefix {
  param(
    [string]$ScriptName,
    [switch]$AddAdminPw,
    [string]$CudnnUrl = $null
  )

  Write-Progress `
    -Activity $ProgressActivity `
    -Status "Running provisioning script $ScriptName in VM" `
    -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

  $DropToAdminUserPrefix = Get-Content "$Root\drop-to-admin-user-prefix.ps1" -Encoding utf8NoBOM -Raw
  $UtilityPrefixContent = Get-Content "$Root\utility-prefix.ps1" -Encoding utf8NoBOM -Raw

  $tempScriptFilename = "$env:TEMP\temp-script.txt"
  try {
    $script = Get-Content "$Root\$ScriptName" -Encoding utf8NoBOM -Raw
    if ($AddAdminPw) {
      $script = $script.Replace('# REPLACE WITH DROP-TO-ADMIN-USER-PREFIX.ps1', $DropToAdminUserPrefix)
    }

    $script = $script.Replace('# REPLACE WITH UTILITY-PREFIX.ps1', $UtilityPrefixContent);
    if (-not [string]::IsNullOrEmpty($CudnnUrl)) {
      $script = $script.Replace('# REPLACE WITH CudnnUrl', "`$CudnnUrl = `"$CudnnUrl`"")
    }

    Set-Content -Path $tempScriptFilename -Value $script -Encoding utf8NoBOM

    $parameter = $null
    if ($AddAdminPw) {
      $parameter = @{AdminUserPassword = $AdminPW;}
    }

    $InvokeResult = Invoke-AzVMRunCommandWithRetries `
      -ResourceGroupName 'vcpkg-image-minting' `
      -VMName $ProtoVMName `
      -CommandId 'RunPowerShellScript' `
      -ScriptPath $tempScriptFilename `
      -Parameter $parameter

    Write-Host "$ScriptName output: $($InvokeResult.value.Message)"
  } finally {
    Remove-Item $tempScriptFilename -Force
  }
}

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-windows-sdks.ps1' -AddAdminPw

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-visual-studio.ps1' -AddAdminPw

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-mpi.ps1' -AddAdminPw

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-cuda.ps1' -AddAdminPw

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-cudnn.ps1' -CudnnUrl $CudnnUrl

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'test-cudnn.ps1'

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-inteloneapi.ps1' -AddAdminPw

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-pwsh.ps1' -AddAdminPw

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Running provisioning script deploy-settings.txt (as a .ps1) in VM' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$ProvisionImageResult = Invoke-AzVMRunCommandWithRetries `
  -ResourceGroupName 'vcpkg-image-minting' `
  -VMName $ProtoVMName `
  -CommandId 'RunPowerShellScript' `
  -ScriptPath "$Root\deploy-settings.txt"

Write-Host "deploy-settings.txt output: $($ProvisionImageResult.value.Message)"
Restart-AzVM -ResourceGroupName 'vcpkg-image-minting' -Name $ProtoVMName

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Running provisioning script sysprep.ps1 in VM' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$SysprepResult = Invoke-AzVMRunCommandWithRetries `
  -ResourceGroupName 'vcpkg-image-minting' `
  -VMName $ProtoVMName `
  -CommandId 'RunPowerShellScript' `
  -ScriptPath "$Root\sysprep.ps1"

Write-Host "sysprep.ps1 output: $($SysprepResult.value.Message)"

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Waiting for VM to shut down' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

Wait-Shutdown -ResourceGroupName 'vcpkg-image-minting' -Name $ProtoVMName

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Converting VM to Image' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

Stop-AzVM `
  -ResourceGroupName 'vcpkg-image-minting' `
  -Name $ProtoVMName `
  -Force

Set-AzVM `
  -ResourceGroupName 'vcpkg-image-minting' `
  -Name $ProtoVMName `
  -Generalized

New-AzGalleryImageVersion `
  -ResourceGroupName 'vcpkg-image-minting' `
  -GalleryName 'vcpkg_gallery_wus3' `
  -GalleryImageDefinitionName 'PrWinWus3-TrustedLaunch' `
  -Name $GalleryImageVersion `
  -Location $Location `
  -SourceImageId $VMCreated.ID `
  -ReplicaCount 1 `
  -StorageAccountType 'Premium_LRS' `
  -PublishingProfileExcludeFromLatest

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Deleting unused temporary resources' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

Remove-AzVM -Id $VMCreated.ID -Force
Remove-AzDisk -ResourceGroupName 'vcpkg-image-minting' -Name $VMCreatedOsDisk -Force
Remove-AzNetworkInterface -ResourceGroupName 'vcpkg-image-minting' -Name $NicName -Force

####################################################################################################
Write-Progress -Activity $ProgressActivity -Completed
Write-Host "Generated Image:  $GalleryImageVersion"
Write-Host 'Finished!'
