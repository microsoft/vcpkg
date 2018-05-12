[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()][string]$disableMetrics = "0",
    [Parameter(Mandatory = $False)][string]$withVSPath = "",
    [Switch]$win64
)
Set-StrictMode -Version Latest
$scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"
$vcpkgRootDir = vcpkgFindFileRecursivelyUp $scriptsDir .vcpkg-root
Write-Verbose("vcpkg Path " + $vcpkgRootDir)

$gitHash = "unknownhash"
$oldpath = $env:path
try {
    [xml]$asXml = Get-Content "$scriptsDir\vcpkgTools.xml"
    $toolData = $asXml.SelectSingleNode("//tools/tool[@name=`"git`"]")
    $gitFromDownload = "$vcpkgRootDir\downloads\$($toolData.exeRelativePath)"
    $gitDir = split-path -parent $gitFromDownload

    $env:path += ";$gitDir"
    if (Get-Command "git" -ErrorAction SilentlyContinue) {
        $gitHash = git log HEAD -n 1 --format="%cd-%H" --date=short
        if ($LASTEXITCODE -ne 0) {
            $gitHash = "unknownhash"
        }
    }
}
finally {
    $env:path = $oldpath
}
Write-Verbose("Git repo version string is " + $gitHash)

$vcpkgSourcesPath = "$vcpkgRootDir\toolsrc"

if (!(Test-Path $vcpkgSourcesPath)) {
    Write-Error "Unable to determine vcpkg sources directory. '$vcpkgSourcesPath' does not exist."
    return
}

$msbuildExeWithPlatformToolset = & $scriptsDir\findAnyMSBuildWithCppPlatformToolset.ps1 $withVSPath
$msbuildExe = $msbuildExeWithPlatformToolset[0]
$platformToolset = $msbuildExeWithPlatformToolset[1]
$windowsSDK = & $scriptsDir\getWindowsSDK.ps1

$platform = "x86"
$vcpkgReleaseDir = "$vcpkgSourcesPath\Release"
# x86_64 architecture is 9
$architecture=(Get-WmiObject win32_Processor -ErrorAction SilentlyContinue).Architecture

if ([Environment]::Is64BitOperatingSystem -and $architecture -eq 9  -and $win64) {
    Write-Host "Try to build vcpkg win64 binary"
    $platform = "x64"
    $vcpkgReleaseDir = "$vcpkgSourcesPath\x64\Release"
}

$arguments = (
    "`"/p:VCPKG_VERSION=-$gitHash`"",
    "`"/p:DISABLE_METRICS=$disableMetrics`"",
    "/p:Configuration=Release",
    "/p:Platform=$platform",
    "/p:PlatformToolset=$platformToolset",
    "/p:TargetPlatformVersion=$windowsSDK",
    "/m",
    "`"$vcpkgSourcesPath\dirs.proj`"") -join " "

# vcpkgInvokeCommandClean cmd "/c echo %PATH%"
$ec = vcpkgInvokeCommandClean $msbuildExe $arguments

if ($ec -ne 0) {
    Write-Error "Building vcpkg.exe failed. Please ensure you have installed Visual Studio with the Desktop C++ workload and the Windows SDK for Desktop C++."
    return
}

Write-Verbose("Placing vcpkg.exe in the correct location")

Copy-Item "$vcpkgReleaseDir\vcpkg.exe" "$vcpkgRootDir\vcpkg.exe" | Out-Null
Copy-Item "$vcpkgReleaseDir\vcpkgmetricsuploader.exe" "$vcpkgRootDir\scripts\vcpkgmetricsuploader.exe" | Out-Null
