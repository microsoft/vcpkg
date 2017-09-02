[CmdletBinding()]
param(
    [Parameter(Mandatory=$False)]
    [switch]$DisableVS2017 = $False,

    [Parameter(Mandatory=$False)]
    [switch]$DisableVS2015 = $False,

    [Parameter(Mandatory=$False)]
    [switch]$DisableVS2013 = $False
)

if ($DisableVS2017 -and $DisableVS2015 -and $DisableVS2013)
{
    throw "VS013, VS2015 and VS2017 were disabled."
}

function New-MSBuildInstance()
{
    param ($msbuildExePath, $toolsetVersion)

    $instance = new-object PSObject
    $instance | add-member -type NoteProperty -Name msbuildExePath -Value $msbuildExePath
    $instance | add-member -type NoteProperty -Name toolsetVersion -Value $toolsetVersion

    return $instance
}

Write-Verbose "Executing $($MyInvocation.MyCommand.Name) with DisableVS2017=$DisableVS2017, DisableVS2015=$DisableVS2015, DisableVS2013=$DisableVS2013"
$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition

$validInstances = New-Object System.Collections.ArrayList

# VS2017
Write-Verbose "`n`n"
Write-Verbose "Checking for MSBuild from VS2017 instances..."
$VisualStudio2017InstallationInstances = & $scriptsDir\findVisualStudioInstallationInstances.ps1
Write-Verbose "VS2017 Candidates: $([system.String]::Join(',', $VisualStudio2017InstallationInstances))"
foreach ($instanceCandidate in $VisualStudio2017InstallationInstances)
{
    $VCFolder= "$instanceCandidate\VC\Tools\MSVC\"

    if (Test-Path $VCFolder)
    {
        $instance = New-MSBuildInstance "$instanceCandidate\MSBuild\15.0\Bin\MSBuild.exe" "v141"
        Write-Verbose "Found $instance"
        $validInstances.Add($instance) > $null
    }
}

# VS2015 - in Program Files
Write-Verbose "`n`n"
Write-Verbose "Checking for MSBuild from VS2015 in Program Files..."
$CandidateProgramFiles = $(& $scriptsDir\getProgramFiles32bit.ps1), $(& $scriptsDir\getProgramFilesPlatformBitness.ps1)
Write-Verbose "Program Files Candidate locations: $([system.String]::Join(',', $CandidateProgramFiles))"
foreach ($ProgramFiles in $CandidateProgramFiles)
{
    $clExe= "$ProgramFiles\Microsoft Visual Studio 14.0\VC\bin\cl.exe"

    if (!(Test-Path $clExe))
    {
        Write-Verbose "$clExe - Not Found"
        continue
    }

    Write-Verbose "$clExe - Found"
    $instance = New-MSBuildInstance "$ProgramFiles\MSBuild\14.0\Bin\MSBuild.exe" "v140"
    Write-Verbose "Found $instance"
    $validInstances.Add($instance) > $null
}

# VS2015 - through the registry
function NewCppRegistryPair()
{
    param ($visualStudioEntry, $msBuildEntry)

    $instance = new-object PSObject
    $instance | add-member -type NoteProperty -Name visualStudioEntry -Value $visualStudioEntry
    $instance | add-member -type NoteProperty -Name msBuildEntry -Value $msBuildEntry

    return $instance
}

Write-Verbose "`n`n"
Write-Verbose "Checking for MSBuild from VS2015 through the registry..."

$registryPairs =
$(NewCppRegistryPair "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\visualstudio\14.0" "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\msbuild\toolsversions\14.0"),
$(NewCppRegistryPair "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\visualstudio\14.0" "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\msbuild\toolsversions\14.0")

foreach ($pair in $registryPairs)
{
    $vsEntry = $pair.visualStudioEntry
    try
    {
        $VS14InstallDir = $(gp $vsEntry InstallDir -erroraction Stop | % { $_.InstallDir })
        Write-Verbose "$vsEntry\InstallDir - Found"
    }
    catch
    {
        Write-Verbose "$vsEntry\InstallDir - Not Found"
        continue
    }

    Write-Verbose "$VS14InstallDir - Obtained from registry"
    # We want "${VS14InstallDir}..\..\VC\bin\cl.exe"
    # Doing Split-path to avoid the ..\.. from appearing in the output
    $clExePath = Split-path $VS14InstallDir -Parent
    $clExePath = Split-path $clExePath -Parent
    $clExePath = "$clExePath\VC\bin\cl.exe"

    if (!(Test-Path $clExePath))
    {
        Write-Verbose "$clExePath - Not Found"
        continue
    }

    Write-Verbose "$clExePath - Found"

    $msbuildEntry = $pair.msBuildEntry
    try
    {
        $MSBuild14 = $(gp $msbuildEntry MSBuildToolsPath -erroraction Stop | % { $_.MSBuildToolsPath })
        Write-Verbose "$msbuildEntry\MSBuildToolsPath - Found"
    }
    catch
    {
        Write-Verbose "$msbuildEntry\MSBuildToolsPath - Not Found"
        continue
    }

    Write-Verbose "${MSBuild14} - Obtained from registry"
    $msbuildPath = "${MSBuild14}MSBuild.exe"
    if (!(Test-Path $msbuildPath))
    {
        Write-Verbose "$msbuildPath - Not Found"
        continue
    }

    $instance = New-MSBuildInstance $msbuildPath "v140"
    Write-Verbose "Found $instance"
    $validInstances.Add($instance) > $null
}

# VS2013 - in Program Files
Write-Verbose "`n`n"
Write-Verbose "Checking for MSBuild from VS2013 in Program Files..."
$CandidateProgramFiles = $(& $scriptsDir\getProgramFiles32bit.ps1), $(& $scriptsDir\getProgramFilesPlatformBitness.ps1)
Write-Verbose "Program Files Candidate locations: $([system.String]::Join(',', $CandidateProgramFiles))"
foreach ($ProgramFiles in $CandidateProgramFiles)
{
    $clExe= "$ProgramFiles\Microsoft Visual Studio 12.0\VC\bin\cl.exe"

    if (!(Test-Path $clExe))
    {
        Write-Verbose "$clExe - Not Found"
        continue
    }

    Write-Verbose "$clExe - Found"
    $instance = New-MSBuildInstance "$ProgramFiles\MSBuild\12.0\Bin\MSBuild.exe" "v120"
    Write-Verbose "Found $instance"
    $validInstances.Add($instance) > $null
}

Write-Verbose "`n`n`n"
Write-Verbose "The following MSBuild instances were found:"
foreach ($instance in $validInstances)
{
    Write-Verbose $instance
}

# Selecting
foreach ($instance in $validInstances)
{
    if (!$DisableVS2017 -and $instance.toolsetVersion -eq "v141")
    {
        return $instance.msbuildExePath, $instance.toolsetVersion
    }

    if (!$DisableVS2015 -and $instance.toolsetVersion -eq "v140")
    {
        return $instance.msbuildExePath, $instance.toolsetVersion
    }

    if (!$DisableVS2013 -and $instance.toolsetVersion -eq "v120")
    {
        return $instance.msbuildExePath, $instance.toolsetVersion
    }
}


throw "Could not find MSBuild version with C++ support. VS2013, VS2015 or VS2017 (with C++) needs to be installed."