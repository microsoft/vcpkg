[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$vsInstallNickname,
    [Parameter(Mandatory=$true)][string]$tfsBranch,
    [Parameter(Mandatory=$true)][string]$triplet,
    [Parameter(Mandatory=$true)][bool]$incremental
)

$vsInstallNickname = $vsInstallNickname.ToLower()
$tfsBranch = $tfsBranch.ToLower()
$triplet = $triplet.ToLower()

$scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"
. "$scriptsDir\VcpkgPowershellUtils-Private.ps1"

$vcpkgRootDir = vcpkgFindFileRecursivelyUp $scriptsDir .vcpkg-root

# Re-exclude "C:\" from Windows Defender because it looks like the exclusion list is cleared on Windows Update
Add-MpPreference -ExclusionPath "C:\"

# Update the relevant Visual Studio installation
$vsInstallPath = findVSInstallPathFromNickname($vsInstallNickname)
UnattendedVSupdate -installPath $vsInstallPath

# For unstable builds, deploy the custom build archive
if ($vsInstallNickname -eq $VISUAL_STUDIO_2017_UNSTABLE_NICKNAME -and ![string]::IsNullOrEmpty($tfsBranch))
{
    & $scriptsDir\DeployBuildArchive.ps1 -tfsBranch $tfsBranch -latest
}

# Create triplets
CreateTripletsForVS -vsInstallPath $vsInstallPath -vsInstallNickname $vsInstallNickname -outputDir "$vcpkgRootDir\triplets"

# Preare installed dir
& $scriptsDir\PrepareInstalledDir.ps1 -triplet $triplet -incremental $incremental