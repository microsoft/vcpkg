[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$triplet,
    [Parameter(Mandatory=$true)][string]$buildId,
    [Parameter(Mandatory=$true)][bool]$recordHeaderList = $false
)

Set-StrictMode -Version Latest

$triplet = $triplet.ToLower()

$scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"
. "$scriptsDir\VcpkgPowershellUtils-Private.ps1"

$vcpkgRootDir = vcpkgFindFileRecursivelyUp $scriptsDir .vcpkg-root

# Copy summary to Vcpkg-000
& $scriptsDir\CopySummaryToVcpkg000.ps1 -triplet $triplet -buildId $buildId

# Delete all logs
if (Test-Path $vcpkgRootDir/buildtrees)
{
    $logs = Get-ChildItem $vcpkgRootDir/buildtrees/*/* | ? { $_.Extension -eq ".log" }
    $logs | Remove-Item
}

if ($recordHeaderList)
{
    cmd /c dir "$vcpkgRootDir\installed\$triplet\include" *.h /s /B > "$triplet-headersList.txt"
}

vcpkgRemoveItem "$vcpkgRootDir\installed"
