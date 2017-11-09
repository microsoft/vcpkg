[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$disableMetrics = "0"
)

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition
$vcpkgRootDir = & $scriptsDir\findFileRecursivelyUp.ps1 $scriptsDir .vcpkg-root
Write-Verbose("vcpkg Path " + $vcpkgRootDir)


$gitHash = "unknownhash"
$oldpath = $env:path
try
{
    $env:path += ";$vcpkgRootDir\downloads\MinGit-2.15.0-32-bit\cmd"
    if (Get-Command "git" -ErrorAction SilentlyContinue)
    {
        $gitHash = git log HEAD -n 1 --format="%cd-%H" --date=short
        if ($LASTEXITCODE -ne 0)
        {
            $gitHash = "unknownhash"
        }
    }
}
finally
{
    $env:path = $oldpath
}
Write-Verbose("Git repo version string is " + $gitHash)
$vcpkgSourcesPath = "$vcpkgRootDir\toolsrc"

if (!(Test-Path $vcpkgSourcesPath))
{
    Write-Error "Unable to determine vcpkg sources directory. '$vcpkgSourcesPath' does not exist."
    return
}

try
{
    pushd $vcpkgSourcesPath
    $msbuildExeWithPlatformToolset = & $scriptsDir\findAnyMSBuildWithCppPlatformToolset.ps1
    $msbuildExe = $msbuildExeWithPlatformToolset[0]
    $platformToolset = $msbuildExeWithPlatformToolset[1]
    $windowsSDK = & $scriptsDir\getWindowsSDK.ps1
    & $msbuildExe "/p:VCPKG_VERSION=-$gitHash" "/p:DISABLE_METRICS=$disableMetrics" /p:Configuration=Release /p:Platform=x86 /p:PlatformToolset=$platformToolset /p:TargetPlatformVersion=$windowsSDK /m dirs.proj
    if ($LASTEXITCODE -ne 0)
    {
        Write-Error "Building vcpkg.exe failed. Please ensure you have installed the Desktop C++ workload and the Windows SDK for Desktop C++."
        return
    }

    Write-Verbose("Placing vcpkg.exe in the correct location")

    Copy-Item $vcpkgSourcesPath\Release\vcpkg.exe $vcpkgRootDir\vcpkg.exe | Out-Null
    Copy-Item $vcpkgSourcesPath\Release\vcpkgmetricsuploader.exe $vcpkgRootDir\scripts\vcpkgmetricsuploader.exe | Out-Null
}
finally
{
    popd
}
