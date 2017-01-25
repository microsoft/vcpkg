[CmdletBinding()]
param(

)

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition

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

# VS2015
$CandidateProgramFiles = "${env:PROGRAMFILES(X86)}", "${env:PROGRAMFILES}"
foreach ($ProgramFiles in $CandidateProgramFiles)
{
    $clExe= "$ProgramFiles\Microsoft Visual Studio 14.0\\VC\bin\cl.exe"

    if (Test-Path $clExe)
    {
        return "$ProgramFiles\MSBuild\14.0\Bin\MSBuild.exe","v140"
    }
}

throw "Could not find MSBuild with C++ support. VS2015 or above with C++ support need to be installed."