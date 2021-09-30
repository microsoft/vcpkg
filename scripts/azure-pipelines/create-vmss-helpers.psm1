# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

<#
.SYNOPSIS
Returns whether there's a name collision in the resource group.

.DESCRIPTION
Find-ResourceGroupNameCollision takes a list of resources, and checks if $Test
collides names with any of the resources.

.PARAMETER Test
The name to test.

.PARAMETER Resources
The list of resources.
#>
function Find-ResourceGroupNameCollision {
  [CmdletBinding()]
  Param([string]$Test, $Resources)

  foreach ($resource in $Resources) {
    if ($resource.ResourceGroupName -eq $Test) {
      return $true
    }
  }

  return $false
}

<#
.SYNOPSIS
Attempts to find a name that does not collide with any resources in the resource group.

.DESCRIPTION
Find-ResourceGroupName takes a set of resources from Get-AzResourceGroup, and finds the
first name in {$Prefix, $Prefix-1, $Prefix-2, ...} such that the name doesn't collide with
any of the resources in the resource group.

.PARAMETER Prefix
The prefix of the final name; the returned name will be of the form "$Prefix(-[1-9][0-9]*)?"
#>
function Find-ResourceGroupName {
  [CmdletBinding()]
  Param([string] $Prefix)

  $resources = Get-AzResourceGroup
  $result = $Prefix
  $suffix = 0
  while (Find-ResourceGroupNameCollision -Test $result -Resources $resources) {
    $suffix++
    $result = "$Prefix-$suffix"
  }

  return $result
}

<#
.SYNOPSIS
Returns whether there's a name collision for an image in the resource group.

.DESCRIPTION
Find-ImageNameCollision takes a list of images, and checks if $Test
collides names with any of the image names.

.PARAMETER Test
The name to test.

.PARAMETER Images
The list of images.
#>
function Find-ImageNameCollision {
  [CmdletBinding()]
  Param([string]$Test, $Images)

  foreach ($resource in $Images) {
    if ($resource.Name -eq $Test) {
      return $true
    }
  }

  return $false
}

<#
.SYNOPSIS
Attempts to find a name that does not collide with any images in the resource group.

.DESCRIPTION
Find-ResourceGroupName takes a set of resources from Get-AzResourceGroup, and finds the
first name in {$Prefix, $Prefix-1, $Prefix-2, ...} such that the name doesn't collide with
any of the resources in the resource group.

.PARAMETER Prefix
The prefix of the final name; the returned name will be of the form "$Prefix(-[1-9][0-9]*)?"
#>
function Find-ImageName {
  [CmdLetBinding()]
  Param([string]$ResourceGroupName, [string]$Prefix)

  $images = Get-AzImage -ResourceGroupName $ResourceGroupName
  $result = $Prefix
  $suffix = 0
  while (Find-ImageNameCollision -Test $result -Images $images) {
    $suffix++
    $result = "$Prefix-$suffix"
  }

  return $result
}

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

  # This 64-character alphabet generates 6 bits of entropy per character.
  # The power-of-2 alphabet size allows us to select a character by masking a random Byte with bitwise-AND.
  $alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-"
  $mask = 63
  if ($alphabet.Length -ne 64) {
    throw 'Bad alphabet length'
  }

  [Byte[]]$randomData = [Byte[]]::new($Length)
  $rng = $null
  try {
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($randomData)
  }
  finally {
    if ($null -ne $rng) {
      $rng.Dispose()
    }
  }

  $result = ''
  for ($idx = 0; $idx -lt $Length; $idx++) {
    $result += $alphabet[$randomData[$idx] -band $mask]
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

<#
.SYNOPSIS
Sanitizes a name to be used in a storage account.

.DESCRIPTION
Sanitize-Name takes a string, and removes all of the '-'s and
lowercases the string, since storage account names must have no
'-'s and must be completely lowercase alphanumeric. It then makes
certain that the length of the string is not greater than 24,
since that is invalid.

.PARAMETER RawName
The name to sanitize.
#>
function Sanitize-Name {
  [CmdletBinding()]
  Param(
    [string]$RawName
  )

  $result = $RawName.Replace('-', '').ToLowerInvariant()
  if ($result.Length -gt 24) {
    Write-Error 'Sanitized name for storage account $result was too long.'
    throw
  }

  return $result
}

<#
.SYNOPSIS
Creates a new Azure virtual network with locked down firewall rules.

.PARAMETER ResourceGroupName
The name of the resource group in which the virtual network should be created.

.PARAMETER Location
The location (region) where the network is to be created.
#>
function Create-LockedDownNetwork {
  [CmdletBinding()]
  Param(
    [parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    [parameter(Mandatory=$true)]
    [string]$Location
  )

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

  return $VirtualNetwork
}

function Invoke-AzVMRunCommandWithRetries {
  try {
    return Invoke-AzVMRunCommand @args
  } catch {
    for ($idx = 0; $idx -lt 5; $idx++) {
      Write-Host "Running command failed. $_ Retrying after 10 seconds..."
      Start-Sleep -Seconds 10
      try {
        return Invoke-AzVMRunCommand @args
      } catch {
        # ignore
      }
    }

    Write-Host "Running command failed too many times. Giving up!"
    throw $_
  }
}

Export-ModuleMember -Function Find-ResourceGroupName
Export-ModuleMember -Function Find-ImageName
Export-ModuleMember -Function New-Password
Export-ModuleMember -Function Wait-Shutdown
Export-ModuleMember -Function Sanitize-Name
Export-ModuleMember -Function Create-LockedDownNetwork
Export-ModuleMember -Function Invoke-AzVMRunCommandWithRetries
