[CmdletBinding()]
param(

)

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition
$vcpkgRootDir = & $scriptsDir\findFileRecursivelyUp.ps1 $scriptsDir .vcpkg-root

$downloadsDir = "$vcpkgRootDir\downloads"

$nugetexe = & $scriptsDir\fetchDependency.ps1 "nuget"
$nugetPackageDir = "$downloadsDir\nuget-packages"

$SetupAPIVersion = "1.8.24"
Write-Verbose "Fetching Microsoft.VisualStudio.Setup.Configuration.Native@$SetupAPIVersion from NuGet."
$nugetOutput = & $nugetexe install Microsoft.VisualStudio.Setup.Configuration.Native -Version $SetupAPIVersion -OutputDirectory $nugetPackageDir -Source "https://api.nuget.org/v3/index.json" -nocache 2>&1
Write-Verbose "Fetching Microsoft.VisualStudio.Setup.Configuration.Native@$SetupAPIVersion from NuGet. Done."

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
