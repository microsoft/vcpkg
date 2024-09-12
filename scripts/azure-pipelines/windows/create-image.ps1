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

<#
.SYNOPSIS
Generates a random password.

.DESCRIPTION
New-Password generates a password, randomly, of length $Length, containing
only alphanumeric characters, underscore, and dash.

.PARAMETER Length
The length of the returned password.
#>
function New-Password {
  Param ([int] $Length = 32)
  $alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-"
  if ($alphabet.Length -ne 64) {
    throw 'Bad alphabet length'
  }

  $result = New-Object SecureString
  for ($idx = 0; $idx -lt $Length; $idx++) {
    $result.AppendChar($alphabet[(Get-SecureRandom -Maximum $alphabet.Length)])
  }

  return $result
}

<#
.SYNOPSIS
Waits for the shutdown of the specified resource.

.DESCRIPTION
Wait-Shutdown takes a VM, and checks if there's a 'PowerState/stopped'
code; if there is, it returns. If there isn't, it waits ten seconds and
tries again.

.PARAMETER ResourceGroupName
The name of the resource group to look up the VM in.

.PARAMETER Name
The name of the virtual machine to wait on.
#>
function Wait-Shutdown {
  [CmdletBinding()]
  Param([string]$ResourceGroupName, [string]$Name)

  Write-Host "Waiting for $Name to stop..."
  while ($true) {
    $Vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $Name -Status
    $highestStatus = $Vm.Statuses.Count
    for ($idx = 0; $idx -lt $highestStatus; $idx++) {
      if ($Vm.Statuses[$idx].Code -eq 'PowerState/stopped') {
        return
      }
    }

    Write-Host "... not stopped yet, sleeping for 10 seconds"
    Start-Sleep -Seconds 10
  }
}


$AdminPW = New-Password
$Credential = New-Object System.Management.Automation.PSCredential ("AdminUser", $AdminPW)

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
  -Status 'Minting token for vcpkg-image-minting storage account' `
  -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

$VcpkgImageMintingAccount = Get-AzStorageAccount -ResourceGroupName 'vcpkg-image-minting' -Name 'vcpkgimageminting'

$AssetStorageContext = New-AzStorageContext -StorageAccountName 'vcpkgimageminting' -UseConnectedAccount
$StartTime = Get-Date
$ExpiryTime = $StartTime.AddHours(4)
$AssetsSas = New-AzStorageContainerSASToken -Name 'assets' -Permission r -StartTime $StartTime -ExpiryTime $ExpiryTime -Context $AssetStorageContext

####################################################################################################
function Invoke-ScriptWithPrefix {
  param(
    [string]$ScriptName,
    [switch]$SkipSas
  )

  Write-Progress `
    -Activity $ProgressActivity `
    -Status "Running provisioning script $ScriptName in VM" `
    -PercentComplete (100 / $TotalProgress * $CurrentProgress++)

  $UtilityPrefixContent = Get-Content "$Root\utility-prefix.ps1" -Encoding utf8NoBOM -Raw

  $tempScriptFilename = "$env:TEMP\temp-script.txt"
  try {
    $script = Get-Content "$Root\$ScriptName" -Encoding utf8NoBOM -Raw
$replacement = @"
if (Test-Path "`$PSScriptRoot/utility-prefix.ps1") {
  . "`$PSScriptRoot/utility-prefix.ps1"
}
"@
    $script = $script.Replace($replacement, $UtilityPrefixContent);
    Set-Content -Path $tempScriptFilename -Value $script -Encoding utf8NoBOM

    $parameter = $null
    if (-not $SkipSas) {
      $parameter = @{SasToken = "`"$AssetsSas`"";}
    }

    $InvokeResult = Invoke-AzVMRunCommand `
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
Invoke-ScriptWithPrefix -ScriptName 'deploy-tlssettings.ps1' -SkipSas
Write-Host 'Waiting 1 minute for VM to reboot...'
Start-Sleep -Seconds 60

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-windows-sdks.ps1'

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-visual-studio.ps1'

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-mpi.ps1'

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-cuda.ps1'

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-cudnn.ps1'

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-inteloneapi.ps1'

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-pwsh.ps1'

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-azure-cli.ps1'

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'deploy-settings.txt' -SkipSas
Restart-AzVM -ResourceGroupName 'vcpkg-image-minting' -Name $ProtoVMName

####################################################################################################
Invoke-ScriptWithPrefix -ScriptName 'sysprep.ps1'

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

$westus3Location = @{Name = 'West US 3';}
$southEastAsiaLocation = @{Name = 'Southeast Asia';}

New-AzGalleryImageVersion `
  -ResourceGroupName 'vcpkg-image-minting' `
  -GalleryName 'vcpkg_gallery_wus3' `
  -GalleryImageDefinitionName 'PrWinWus3-TrustedLaunch' `
  -Name $GalleryImageVersion `
  -Location $Location `
  -SourceImageVMId $VMCreated.ID `
  -ReplicaCount 1 `
  -StorageAccountType 'Premium_LRS' `
  -PublishingProfileExcludeFromLatest `
  -TargetRegion @($westus3Location, $southEastAsiaLocation)

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

$AdminPW.Dispose()
