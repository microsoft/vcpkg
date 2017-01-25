[CmdletBinding()]
param(

)

Import-Module BitsTransfer

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition
$vcpkgRootDir = & $scriptsDir\findFileRecursivelyUp.ps1 $scriptsDir .vcpkg-root

$downloadsDir = "$vcpkgRootDir\downloads"

$nugetexe = & $scriptsDir\fetchDependency.ps1 "nuget"
$nugetPackageDir = "$downloadsDir\nuget-packages"

$SetupAPIVersion = "1.3.269-rc"
$url = "https://api.nuget.org/packages/microsoft.visualstudio.setup.configuration.native.$SetupAPIVersion.nupkg"
$downloadName = "microsoft.visualstudio.setup.configuration.native.$SetupAPIVersion.nupkg"
$downloadPath = "$downloadsDir\$downloadName"

if (!(Test-Path $downloadPath))
{
    Start-BitsTransfer -Source $url -Destination $downloadPath #-ErrorAction SilentlyContinue
}

$nugetOutput = & $nugetexe install Microsoft.VisualStudio.Setup.Configuration.Native -Pre -Source $downloadsDir -OutputDirectory $nugetPackageDir 2>&1

$SetupConsoleExe = "$nugetPackageDir\Microsoft.VisualStudio.Setup.Configuration.Native.$SetupAPIVersion\tools\x86\Microsoft.VisualStudio.Setup.Configuration.Console.exe"

if (!(Test-Path $SetupConsoleExe))
{
    throw $nugetOutput
}

$consoleOutput = & $SetupConsoleExe 2>&1

$key = "InstallationPath = "
$paths = $consoleOutput | Select-String  -SimpleMatch $key
$paths = $paths -replace $key, ""
return $paths