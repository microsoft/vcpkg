[CmdletBinding()]
param(

)

Import-Module BitsTransfer

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition
$vcpkgRootDir = & $scriptsDir\findFileRecursivelyUp.ps1 $scriptsDir .vcpkg-root

$downloadsDir = "$vcpkgRootDir\downloads"

$nugetexe = & $scriptsDir\fetchDependency.ps1 "nuget"
$nugetPackageDir = "$downloadsDir\nuget-packages"

$SetupAPIVersion = "1.5.125-rc"
$nugetOutput = & $nugetexe install Microsoft.VisualStudio.Setup.Configuration.Native -Version $SetupAPIVersion -OutputDirectory $nugetPackageDir -nocache 2>&1

$SetupConsoleExe = "$nugetPackageDir\Microsoft.VisualStudio.Setup.Configuration.Native.$SetupAPIVersion\tools\x86\Microsoft.VisualStudio.Setup.Configuration.Console.exe"

if (!(Test-Path $SetupConsoleExe))
{
    throw $nugetOutput
}

$instances = & $SetupConsoleExe -nologo -value InstallationPath 2>&1
$instanceCount = $instances.Length

# The last item can be empty
if ($instanceCount -gt 0 -and $instances[$instanceCount - 1] -eq "")
{
    $instances = $instances[0..($instanceCount - 2)]
}

return $instances
