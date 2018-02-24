[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$triplet,
    [Parameter(Mandatory=$true)][bool]$miniTest
)

Set-StrictMode -Version Latest

$scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"
. "$scriptsDir\VcpkgPowershellUtils-Private.ps1"

$vcpkgRootDir = vcpkgFindFileRecursivelyUp $scriptsDir .vcpkg-root

$tripletFilePath = "$vcpkgRootDir\triplets\$triplet.cmake"
$vsInstallPath = findVSInstallPathFromTriplet $tripletFilePath

Write-Host "Bootstrapping vcpkg ..."
& "$vcpkgRootDir\scripts\bootstrap.ps1" -Verbose -withVSPath $vsInstallPath
Write-Host "Bootstrapping vcpkg ... done."

$packagesDir = "$vcpkgRootDir\packages"
Write-Host "Deleting $packagesDir ..."
vcpkgRemoveItem "$packagesDir"
Write-Host "Deleting $packagesDir ... done."

$ciXmlPath = "$vcpkgRootDir\test-full-ci.xml"

Write-Host "Deleting $ciXmlPath ..."
vcpkgRemoveItem $ciXmlPath
Write-Host "Deleting $ciXmlPath ... done."

./vcpkg remove --outdated --recurse

cmd /c subst V: /D
cmd /c subst V: .

pushd V:\

if($miniTest)
{
    ./vcpkg install "zlib:$Triplet" "--x-xunit=$ciXmlPath" | Tee-Object -FilePath "$triplet.txt"
}
else
{
    ./vcpkg ci $Triplet "--x-xunit=$ciXmlPath" --exclude=aws-sdk-cpp,ecm,llvm,catch-classic,libpng-apng,libmariadb,libp7-baical | Tee-Object -FilePath "$triplet.txt"
}

popd