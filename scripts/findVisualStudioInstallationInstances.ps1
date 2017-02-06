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
    try {
        Start-BitsTransfer -Source $url -Destination $downloadPath -ErrorAction Stop
    }
    catch [System.Exception] {
        # If BITS fails for any reason, delete any potentially partially downloaded files and continue
        if (Test-Path $downloadPath)
        {
            Remove-Item $downloadPath
        }
    }
}
if (!(Test-Path $downloadPath))
{
    Write-Host("Downloading $downloadName...")
    (New-Object System.Net.WebClient).DownloadFile($url, $downloadPath)
}

$nugetOutput = & $nugetexe install Microsoft.VisualStudio.Setup.Configuration.Native -Pre -Source $downloadsDir -OutputDirectory $nugetPackageDir 2>&1

$SetupConsoleExe = "$nugetPackageDir\Microsoft.VisualStudio.Setup.Configuration.Native.$SetupAPIVersion\tools\x86\Microsoft.VisualStudio.Setup.Configuration.Console.exe"

if (!(Test-Path $SetupConsoleExe))
{
    throw $nugetOutput
}

$instances = & $SetupConsoleExe -nologo -value InstallationPath 2>&1
$instanceCount = $instances.Length
# The last item can be empty
if ($instances[$entryCount - 1] -eq "")
{
    $instances = $instances[0..($instanceCount - 2)]
}

return $instances
