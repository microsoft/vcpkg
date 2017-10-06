[CmdletBinding()]
param(

)

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition
$vswhereExe = & $scriptsDir\fetchDependency.ps1 "vswhere"

$output = & $vswhereExe -prerelease -legacy -format xml
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
    $results.Add("${releaseType}::${installationVersion}::${installationPath}") > $null
}

$results.Sort()
$results.Reverse()

return $results