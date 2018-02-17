[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$triplet
)

$triplet = $triplet.ToLower()

$scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"
. "$scriptsDir\VcpkgPowershellUtils-Private.ps1"

$vcpkgRootDir = vcpkgFindFileRecursivelyUp $scriptsDir .vcpkg-root

# Copy summary to Vcpkg-000
& $scriptsDir\CopySummaryToVcpkg000.ps1 -triplet $triplet

# Delete all logs
$logs = Get-ChildItem $vcpkgRootDir/buildtrees/*/* | ? { $_.Extension -eq ".log" }
$logs | Remove-Item