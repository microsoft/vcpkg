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
$installedDir = "$vcpkgRootDir\installed"
Write-Host "Deleting $packagesDir & $installedDir  ..."
vcpkgRemoveItem "$packagesDir"
vcpkgRemoveItem "$installedDir"
Write-Host "Deleting $packagesDir & $installedDir  ... done."

$ciXmlPath = "$vcpkgRootDir\test-full-ci.xml"

Write-Host "Deleting $ciXmlPath ..."
vcpkgRemoveItem $ciXmlPath
Write-Host "Deleting $ciXmlPath ... done."

./vcpkg remove --outdated --recurse

cmd /c subst V: /D
cmd /c subst V: .

pushd V:\

$env:VCPKG_FEATURE_FLAGS = "binarycaching"

if($miniTest)
{
    ./vcpkg install "zlib:$triplet" "--x-xunit=$ciXmlPath" | Tee-Object -FilePath "$triplet.txt"
}
else
{
    ./vcpkg ci $triplet "--x-xunit=$ciXmlPath" --exclude=aws-sdk-cpp,ecm,llvm,catch-classic,libpng-apng,libmariadb,libp7-baical,luajit,mozjpeg | Tee-Object -FilePath "$triplet.txt"
}

popd