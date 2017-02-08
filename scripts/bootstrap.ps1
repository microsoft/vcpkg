[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$disableMetrics = "0"
)

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition
$vcpkgRootDir = & $scriptsDir\findFileRecursivelyUp.ps1 $scriptsDir .vcpkg-root

$gitHash = "unknownhash"
if (Get-Command "git.exe" -ErrorAction SilentlyContinue)
{
    $gitHash = git rev-parse HEAD
}
Write-Verbose("Git hash is " + $gitHash)
$vcpkgSourcesPath = "$vcpkgRootDir\toolsrc"
Write-Verbose("vcpkg Path " + $vcpkgSourcesPath)

if (!(Test-Path $vcpkgSourcesPath))
{
    New-Item -ItemType directory -Path $vcpkgSourcesPath -force | Out-Null
}

try{
    pushd $vcpkgSourcesPath
    $msbuildExeWithPlatformToolset = & $scriptsDir\findAnyMSBuildWithCppPlatformToolset.ps1
    $msbuildExe = $msbuildExeWithPlatformToolset[0]
    $platformToolset = $msbuildExeWithPlatformToolset[1]
    & $msbuildExe "/p:VCPKG_VERSION=-$gitHash" "/p:DISABLE_METRICS=$disableMetrics" /p:Configuration=Release /p:Platform=x86 /p:PlatformToolset=$platformToolset /m dirs.proj

    Write-Verbose("Placing vcpkg.exe in the correct location")

    Copy-Item $vcpkgSourcesPath\Release\vcpkg.exe $vcpkgRootDir\vcpkg.exe | Out-Null
    Copy-Item $vcpkgSourcesPath\Release\vcpkgmetricsuploader.exe $vcpkgRootDir\scripts\vcpkgmetricsuploader.exe | Out-Null
}
finally{
    popd
}
