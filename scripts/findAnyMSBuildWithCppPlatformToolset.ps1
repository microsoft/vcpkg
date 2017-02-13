[CmdletBinding()]
param(
    [Parameter(Mandatory=$False)]
    [switch]$DisableVS2017 = $False,

    [Parameter(Mandatory=$False)]
    [switch]$DisableVS2015 = $False
)

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition

if (-not $DisableVS2017)
{
    # VS2017
    $VisualStudio2017InstallationInstances = & $scriptsDir\findVisualStudioInstallationInstances.ps1
    foreach ($instance in $VisualStudio2017InstallationInstances)
    {
        $VCFolder= "$instance\VC\Tools\MSVC\"

        if (Test-Path $VCFolder)
        {
            return "$instance\MSBuild\15.0\Bin\MSBuild.exe","v141"
        }
    }
}

if (-not $DisableVS2015)
{
    # Try to locate VS2015 through the Registry
    try
    {
        # First ensure the compiler was installed (optional in 2015)
        # In 64-bit systems, this is under the Wow6432Node.
        try
        {
            $VS14InstallDir = $(gp Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\visualstudio\14.0 InstallDir -erroraction Stop | % InstallDir)
            Write-Verbose "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\visualstudio\14.0 - Found"
        }
        catch
        {
            $VS14InstallDir = $(gp Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\visualstudio\14.0 InstallDir -erroraction Stop | % InstallDir)
            Write-Verbose "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\visualstudio\14.0 - Found"
        }
        if (!(Test-Path "${VS14InstallDir}..\..\VC\bin\cl.exe")) { throw }
        Write-Verbose "${VS14InstallDir}..\..\VC\bin\cl.exe - Found"

        $MSBuild14 = $(gp Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\msbuild\toolsversions\14.0 MSBuildToolsPath -erroraction Stop | % MSBuildToolsPath)
        Write-Verbose "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\msbuild\toolsversions\14.0 - Found"
        if (!(Test-Path "${MSBuild14}MSBuild.exe")) { throw }
        Write-Verbose "${MSBuild14}MSBuild.exe - Found"

        return "${MSBuild14}MSBuild.exe","v140"
    }
    catch
    {
        Write-Verbose "Unable to locate a VS2015 installation with C++ support"
    }
}

throw "Could not find MSBuild version with C++ support. VS2015 or VS2017 (with C++) needs to be installed."