[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][ValidateSet('tfs','msvc')][string]$repo,
    [Parameter(Mandatory=$true)][string]$branch,
    [Parameter(Mandatory=$true)][ValidateSet('ret','chk')][string]$retOrChk
)

$scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"
. "$scriptsDir\VcpkgPowershellUtils-Private.ps1"

$prefix = "$repo-$branch-$retOrChk"

$buildArchiveFolderRoot = "\\vcpkg-000\General\CustomBuilds"
$branchBuildArchives = Get-ChildItem $buildArchiveFolderRoot | Where-object -Property name -match "^$prefix.+\.7z$"
$buildArchive = ($branchBuildArchives | Sort-object Name -Descending | Select-object -first 1).fullname
if ([string]::IsNullOrEmpty($buildArchive))
{
    Write-Error "Count not find build archives for branch $prefix in: $buildArchiveFolderRoot"
    throw;
}

$buildArchive
