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

$Location = 'westus2'
$Prefix = 'Win-'
$Prefix += (Get-Date -Format 'yyyy-MM-dd')
$VMSize = 'Standard_D32as_v4'
$ProtoVMName = 'PROTOTYPE'
$WindowsServerSku = '2019-datacenter-gensecond'
$ErrorActionPreference = 'Stop'
$CudnnBaseUrl = 'https://vcpkgimageminting.blob.core.windows.net/assets/cudnn-11.2-windows-x64-v8.1.1.33.zip'

$ProgressActivity = 'Creating Windows Image'
$TotalProgress = 18
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
  -Status 'Running provisioning script deploy-tlssettings.ps1 in VM' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$ProvisionImageResult = Invoke-AzVMRunCommandWithRetries `
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

$DeployPsExecResult = Invoke-AzVMRunCommandWithRetries `
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
    [string]$CudnnUrl
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

    if (-Not ([string]::IsNullOrWhiteSpace($CudnnUrl))) {
      $script = $script.Replace('# REPLACE WITH $CudnnUrl', "`$CudnnUrl = '$CudnnUrl'")
    }

    $script = $script.Replace('# REPLACE WITH UTILITY-PREFIX.ps1', $UtilityPrefixContent);
    Set-Content -Path $tempScriptFilename -Value $script -Encoding utf8NoBOM

    $parameter = $null
    if ($AddAdminPw) {
      $parameter = @{AdminUserPassword = $AdminPW;}
    }

    $InvokeResult = Invoke-AzVMRunCommandWithRetries `
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

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-visual-studio.ps1' -AddAdminPw

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-mpi.ps1' -AddAdminPw

####################################################################################################
$StorageAccountKeys = Get-AzStorageAccountKey `
  -ResourceGroupName 'vcpkg-image-minting' `
  -Name 'vcpkgimageminting'

$StorageContext = New-AzStorageContext `
  -StorageAccountName 'vcpkgimageminting' `
  -StorageAccountKey $StorageAccountKeys[0].Value

$StartTime = [DateTime]::Now
$ExpiryTime = $StartTime.AddDays(1)

$SetupSasToken = New-AzStorageAccountSASToken `
  -Service Blob `
  -Permission "r" `
  -Context $StorageContext `
  -StartTime $StartTime `
  -ExpiryTime $ExpiryTime `
  -ResourceType Object `
  -Protocol HttpsOnly

Invoke-ScriptWithPrefix -ScriptName 'deploy-cuda.ps1' -AddAdminPw -CudnnUrl ($CudnnBaseUrl + $SetupSasToken)

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
  -ResourceGroupName $ResourceGroupName `
  -VMName $ProtoVMName `
  -CommandId 'RunPowerShellScript' `
  -ScriptPath "$PSScriptRoot\deploy-settings.txt"

Write-Host "deploy-settings.txt output: $($ProvisionImageResult.value.Message)"
Restart-AzVM -ResourceGroupName $ResourceGroupName -Name $ProtoVMName

####################################################################################################
Write-Progress `
  -Activity $ProgressActivity `
  -Status 'Running provisioning script sysprep.ps1 in VM' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$SysprepResult = Invoke-AzVMRunCommandWithRetries `
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
