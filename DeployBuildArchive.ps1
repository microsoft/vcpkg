[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][ValidateSet('tfs','msvc')][string]$repo,
    [Parameter(Mandatory=$true)][string]$branch,
    [Parameter(Mandatory=$true)][ValidateSet('ret','chk')][string]$retOrChk,
    [Parameter(ParameterSetName='SetLatest')]
    [switch]$latest,
    [Parameter(ParameterSetName='SetBuildNumber')]
    [string]$buildNumber
)

$scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"
. "$scriptsDir\VcpkgPowershellUtils-Private.ps1"

$prefix = "$repo-$branch-$retOrChk"

$buildArchiveFolderRoot = "\\vcpkg-000\General\CustomBuilds"
if ($latest)
{
    $branchBuildArchives = Get-ChildItem $buildArchiveFolderRoot | Where-object -Property name -match "^$prefix.+\.7z$"
    $buildArchive = ($branchBuildArchives | Sort-object Name -Descending | Select-object -first 1).fullname
    if ([string]::IsNullOrEmpty($buildArchive))
    {
        Write-Error "Count not find build archives for branch $prefix in: $buildArchiveFolderRoot"
        throw;
    }
}
else
{
    $buildArchive = "$buildArchiveFolderRoot\$prefix-$buildNumber.7z"
}

if (!(Test-Path $buildArchive))
{
    Write-Error "$buildArchive was not found"
    throw;
}

Write-Host "Deploying $buildArchive"
$buildArchiveName = Split-Path $buildArchive -leaf
$buildArchiveFileName = ($buildArchiveName -split "\.")[0]


$deploymentRoot = "$VISUAL_STUDIO_2017_UNSTABLE_PATH\VC\Tools\MSVC"
$deployedVersionFile = "$deploymentRoot\$DEPLOYED_VERSION_FILENAME"
$alreadyDeployedVersion = Get-Content $deployedVersionFile -ErrorAction SilentlyContinue
if (![string]::IsNullOrEmpty($alreadyDeployedVersion) -and $alreadyDeployedVersion -eq buildArchiveFileName)
{
    Write-Host "$buildArchive is already deployed, so no need to re-deploy."
    return
}

$msvcVersion = (dir -Directory $deploymentRoot | Sort-object Name -Descending | Select-object -first 1).Name
$deploymentPath = "$deploymentRoot\$msvcVersion"

Write-Host "Cleaning-up $deploymentRoot..."
Get-Process -Name "cl" -ErrorAction SilentlyContinue | Stop-Process
Get-Process -Name "VCTip" -ErrorAction SilentlyContinue | Stop-Process

vcpkgCreateDirectoryIfNotExists $deploymentPath
Get-ChildItem $deploymentRoot -exclude $msvcVersion | % { vcpkgRemoveItem $_ }
Get-ChildItem $deploymentPath -exclude "crt" | % { vcpkgRemoveItem $_ }
Write-Host "Cleaning-up $deploymentRoot... done."

Write-Host "Copying $buildArchive..."
$tempBuildArchive = "$deploymentRoot\$buildArchiveName"
Copy-Item $buildArchive -Destination $tempBuildArchive
Write-Host "Copying $buildArchive... done."

Write-Host "Deployment path: $deploymentPath"
Write-Host "Extracting 7z..."
$time7z = Measure-Command {& $scriptsDir\7za.exe x $tempBuildArchive -o"$deploymentPath" -y}
$formattedTime7z = vcpkgFormatElapsedTime $time7z
Write-Host "Extracting 7z... done. Time Taken: $formattedTime7z seconds"

Write-Host "Writing file: $deployedVersionFile..."
$buildArchiveFileName | Out-File -filepath $deployedVersionFile
Write-Host "Writing file: $deployedVersionFile... done."