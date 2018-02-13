[CmdletBinding()]
param(
)

$scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"

$vcpkgRootDir = vcpkgFindFileRecursivelyUp $scriptsDir .vcpkg-root

$installedDir = "$vcpkgRootDir\installed"
Write-Host "Deleting $installedDir ..."
vcpkgRemoveItem "$installedDir"
Write-Host "Deleting $installedDir ... done."