[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$triplet,
    [Parameter(Mandatory=$true)][bool]$binaryCaching,
    [Parameter(Mandatory=$true)][bool]$miniTest,
    [Parameter(Mandatory=$true)][bool]$noExclusions
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

$ciXmlPath = "$vcpkgRootDir\test-full-ci.xml"
vcpkgRemoveItem $ciXmlPath

./vcpkg remove --outdated --recurse

cmd /c subst V: /D
cmd /c subst V: .

Push-Location V:\

if ($binaryCaching)
{
    $env:VCPKG_FEATURE_FLAGS = "binarycaching"
}

$env:VCPKG_DEFAULT_VS_PATH = $vsInstallPath


if($miniTest)
{
    ./vcpkg install "zlib:$triplet" "--x-xunit=$ciXmlPath" | Tee-Object -FilePath "$triplet.txt"
}
else
{
    $exclusions = "--exclude=aws-sdk-cpp,ecm,llvm,catch-classic,libpng-apng,libmariadb,libp7-baical,luajit,mozjpeg"
    if ($noExclusions)
    {
        $exclusions = ""
    }

    # WORKAROUND: the x86-windows flavors of these are needed for the uwp flavors, but they are not auto-installed.
    # Install them so the CI succeeds
    ./vcpkg install "protobuf:x86-windows" "boost-build:x86-windows"

    # Run the CI
    ./vcpkg ci $triplet "--x-xunit=$ciXmlPath" $exclusions | Tee-Object -FilePath "$triplet.txt"
}

Pop-Location