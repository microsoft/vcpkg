[CmdLetBinding()]
Param(
  [parameter(Mandatory=$true)]
  [string]$ImageName
)
../linux/create-vmss.ps1 -ImageName $ImageName -Prefix "PrAnd-"