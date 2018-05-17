[CmdletBinding()]
param(

)
Set-StrictMode -Version Latest
$scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"

$programFiles = getProgramFiles32bit

$results = New-Object System.Collections.ArrayList

$vswhereExe = "$programFiles\Microsoft Visual Studio\Installer\vswhere.exe"

if (Test-Path $vswhereExe)
{
    $output = & $vswhereExe -prerelease -legacy -products * -format xml
    [xml]$asXml = $output

    foreach ($instance in $asXml.instances.instance)
    {
        $installationPath = $instance.InstallationPath -replace "\\$" # Remove potential trailing backslash
        $installationVersion = $instance.InstallationVersion

        $isPrerelease = -7
        if (vcpkgHasProperty -object $instance -propertyName "isPrerelease")
        {
            $isPrerelease = $instance.isPrerelease
        }

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
}
else
{
    Write-Verbose "Could not locate vswhere at $vswhereExe"
}

if ("$env:vs140comntools" -ne "")
{
    $installationPath = Split-Path -Parent $(Split-Path -Parent "$env:vs140comntools")
    $clExe = "$installationPath\VC\bin\cl.exe"
    $vcvarsallbat = "$installationPath\VC\vcvarsall.bat"

    if ((Test-Path $clExe) -And (Test-Path $vcvarsallbat))
    {
        $results.Add("<sol>::PreferenceWeight1::Legacy::14.0::$installationPath::<eol>") > $null
    }
}

$installationPath = "$programFiles\Microsoft Visual Studio 14.0"
$clExe = "$installationPath\VC\bin\cl.exe"
$vcvarsallbat = "$installationPath\VC\vcvarsall.bat"

if ((Test-Path $clExe) -And (Test-Path $vcvarsallbat))
{
    $results.Add("<sol>::PreferenceWeight1::Legacy::14.0::$installationPath::<eol>") > $null
}

$results.Sort()
$results.Reverse()

return $results
