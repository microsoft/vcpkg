[CmdLetBinding()]
Param(
  [parameter(Mandatory=$true)]
  [string]$ImageName
)
& "$PSScriptRoot/../linux/create-vmss.ps1" -ImageName $ImageName -Prefix "PrAnd-" -AddAndroidContainerRegistryPermissions
