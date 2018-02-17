[CmdletBinding()]
param(
    [string]$Triplet,
    [bool]$miniTest
)

$scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"
. "$scriptsDir\VcpkgPowershellUtils-Private.ps1"

$vcpkgRootDir = vcpkgFindFileRecursivelyUp $scriptsDir .vcpkg-root

$tripletFilePath = "$vcpkgRootDir\triplets\$Triplet.cmake"
$vsInstallPath = findVSInstallPathFromTriplet $tripletFilePath

Write-Host "Bootstrapping vcpkg ..."
& "$vcpkgRootDir\scripts\bootstrap.ps1" -Verbose -withVSPath $vsInstallPath
Write-Host "Bootstrapping vcpkg ... done."

$packagesDir = "$vcpkgRootDir\packages"
Write-Host "Deleting $packagesDir ..."
vcpkgRemoveItem "$packagesDir"
Write-Host "Deleting $packagesDir ... done."

$cixml = "$vcpkgRootDir\TEST-full-ci.xml"

Write-Host "Deleting $cixml ..."
vcpkgRemoveItem "$cixml"
Write-Host "Deleting $cixml ... done."

./vcpkg remove --outdated --recurse

if($miniTest)
{
    ./vcpkg install "zlib:$Triplet" --x-xunit=TEST-full-ci.xml | Tee-Object -FilePath "$Triplet.txt"
}
else
{
    ./vcpkg ci $Triplet --x-xunit=TEST-full-ci.xml --exclude=aws-sdk-cpp | Tee-Object -FilePath "$Triplet.txt"
}
