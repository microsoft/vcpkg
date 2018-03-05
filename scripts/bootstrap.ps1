[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()][string]$disableMetrics = "0",
    [Parameter(Mandatory=$False)][string]$withVSPath = ""
)
Set-StrictMode -Version Latest
$scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"
$vcpkgRootDir = vcpkgFindFileRecursivelyUp $scriptsDir .vcpkg-root
Write-Verbose("vcpkg Path " + $vcpkgRootDir)

$gitHash = "unknownhash"
$oldpath = $env:path
try
{
    [xml]$asXml = Get-Content "$scriptsDir\vcpkgTools.xml"
    $toolData = $asXml.SelectSingleNode("//tools/tool[@name=`"git`"]")
    $gitFromDownload = "$vcpkgRootDir\downloads\$($toolData.exeRelativePath)"
    $gitDir = split-path -parent $gitFromDownload

    $env:path += ";$gitDir"
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

$msbuildExeWithPlatformToolset = & $scriptsDir\findAnyMSBuildWithCppPlatformToolset.ps1 $withVSPath
$msbuildExe = $msbuildExeWithPlatformToolset[0]
$platformToolset = $msbuildExeWithPlatformToolset[1]
$windowsSDK = & $scriptsDir\getWindowsSDK.ps1

$arguments = (
"`"/p:VCPKG_VERSION=-$gitHash`"",
"`"/p:DISABLE_METRICS=$disableMetrics`"",
"/p:Configuration=Release",
"/p:Platform=x86",
"/p:PlatformToolset=$platformToolset",
"/p:TargetPlatformVersion=$windowsSDK",
"/m",
"`"$vcpkgSourcesPath\dirs.proj`"") -join " "

# vcpkgInvokeCommandClean cmd "/c echo %PATH%"
$ec = vcpkgInvokeCommandClean $msbuildExe $arguments

if ($ec -ne 0)
{
    Write-Error "Building vcpkg.exe failed. Please ensure you have installed Visual Studio with the Desktop C++ workload and the Windows SDK for Desktop C++."
    return
}

Write-Verbose("Placing vcpkg.exe in the correct location")

Copy-Item $vcpkgSourcesPath\Release\vcpkg.exe $vcpkgRootDir\vcpkg.exe | Out-Null
Copy-Item $vcpkgSourcesPath\Release\vcpkgmetricsuploader.exe $vcpkgRootDir\scripts\vcpkgmetricsuploader.exe | Out-Null
