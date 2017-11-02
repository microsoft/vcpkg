[CmdletBinding()]
param(

)

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition
$vswhereExe = (& $scriptsDir\fetchDependency.ps1 "vswhere") -replace "<sol>::" -replace "::<eol>"

$output = & $vswhereExe -prerelease -legacy -products * -format xml
[xml]$asXml = $output

$results = New-Object System.Collections.ArrayList
foreach ($instance in $asXml.instances.instance)
{
    $installationPath = $instance.InstallationPath -replace "\\$" # Remove potential trailing backslash
    $installationVersion = $instance.InstallationVersion
    $isPrerelease = $instance.IsPrerelease
    if ($isPrerelease -eq 0)
    {
        $releaseType = "PreferenceWeight3::StableRelease"
    }
    elseif ($isPrerelease -eq 1)
    {
        $releaseType = "PreferenceWeight2::PreRelease"
    }
    else
    {
        $releaseType = "PreferenceWeight1::Legacy"
    }

    # Placed like that for easy sorting according to preference
    $results.Add("<sol>::${releaseType}::${installationVersion}::${installationPath}::<eol>") > $null
}

# If nothing is found, attempt to find VS2015 Build Tools (not detected by vswhere.exe)
if ($results.Count -eq 0)
{
    $programFiles = & $scriptsDir\getProgramFiles32bit.ps1
    $installationPath = "$programFiles\Microsoft Visual Studio 14.0"
    $clExe = "$installationPath\VC\bin\cl.exe"
    $vcvarsallbat = "$installationPath\VC\vcvarsall.bat"

    if ((Test-Path $clExe) -And (Test-Path $vcvarsallbat))
    {
        return "<sol>::PreferenceWeight1::Legacy::14.0::$installationPath::<eol>"
    }
}


$results.Sort()
$results.Reverse()

return $results