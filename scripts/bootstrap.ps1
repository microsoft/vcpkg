[CmdletBinding()]
param(
    $badParam,
    [Parameter(Mandatory=$False)][switch]$disableMetrics = $false,
    [Parameter(Mandatory=$False)][switch]$win64 = $false,
    [Parameter(Mandatory=$False)][string]$withVSPath = "",
    [Parameter(Mandatory=$False)][string]$withWinSDK = ""
)
Set-StrictMode -Version Latest
# Powershell2-compatible way of forcing named-parameters
if ($badParam)
{
    if ($disableMetrics -and $badParam -eq "1")
    {
        Write-Warning "'disableMetrics 1' is deprecated, please change to 'disableMetrics' (without '1')"
    }
    else
    {
        throw "Only named parameters are allowed"
    }
}

$scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
$withVSPath = $withVSPath -replace "\\$" # Remove potential trailing backslash

function vcpkgHasProperty([Parameter(Mandatory=$true)][AllowNull()]$object, [Parameter(Mandatory=$true)]$propertyName)
{
    if ($null -eq $object)
    {
        return $false
    }

    return [bool]($object.psobject.Properties | Where-Object { $_.Name -eq "$propertyName"})
}

function getProgramFiles32bit()
{
    $out = ${env:PROGRAMFILES(X86)}
    if ($null -eq $out)
    {
        $out = ${env:PROGRAMFILES}
    }

    if ($null -eq $out)
    {
        throw "Could not find [Program Files 32-bit]"
    }

    return $out
}

$vcpkgRootDir = $scriptsDir
while (!($vcpkgRootDir -eq "") -and !(Test-Path "$vcpkgRootDir\.vcpkg-root"))
{
    Write-Verbose "Examining $vcpkgRootDir for .vcpkg-root"
    $vcpkgRootDir = Split-path $vcpkgRootDir -Parent
}
Write-Verbose "Examining $vcpkgRootDir for .vcpkg-root - Found"

$vcpkgSourcesPath = "$vcpkgRootDir\toolsrc"

if (!(Test-Path $vcpkgSourcesPath))
{
    Write-Error "Unable to determine vcpkg sources directory. '$vcpkgSourcesPath' does not exist."
    return
}

function getVisualStudioInstances()
{
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
            $results.Add("${releaseType}::${installationVersion}::${installationPath}") > $null
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
            $results.Add("PreferenceWeight1::Legacy::14.0::$installationPath") > $null
        }
    }

    $installationPath = "$programFiles\Microsoft Visual Studio 14.0"
    $clExe = "$installationPath\VC\bin\cl.exe"
    $vcvarsallbat = "$installationPath\VC\vcvarsall.bat"

    if ((Test-Path $clExe) -And (Test-Path $vcvarsallbat))
    {
        $results.Add("PreferenceWeight1::Legacy::14.0::$installationPath") > $null
    }

    $results.Sort()
    $results.Reverse()

    return $results
}

function findAnyMSBuildWithCppPlatformToolset([string]$withVSPath)
{
    $VisualStudioInstances = getVisualStudioInstances
    if ($null -eq $VisualStudioInstances)
    {
        throw "Could not find Visual Studio. VS2015 or VS2017 (with C++) needs to be installed."
    }

    Write-Verbose "VS Candidates:`n`r$([system.String]::Join([Environment]::NewLine, $VisualStudioInstances))"
    foreach ($instanceCandidate in $VisualStudioInstances)
    {
        Write-Verbose "Inspecting: $instanceCandidate"
        $split = $instanceCandidate -split "::"
        # $preferenceWeight = $split[0]
        # $releaseType = $split[1]
        $version = $split[2]
        $path = $split[3]

        if ($withVSPath -ne "" -and $withVSPath -ne $path)
        {
            Write-Verbose "Skipping: $instanceCandidate"
            continue
        }

        $majorVersion = $version.Substring(0,2);
        if ($majorVersion -eq "16")
        {
            $VCFolder= "$path\VC\Tools\MSVC\"
            if (Test-Path $VCFolder)
            {
                Write-Verbose "Picking: $instanceCandidate"
                return "$path\MSBuild\Current\Bin\MSBuild.exe", "v142"
            }
        }

        if ($majorVersion -eq "15")
        {
            $VCFolder= "$path\VC\Tools\MSVC\"
            if (Test-Path $VCFolder)
            {
                Write-Verbose "Picking: $instanceCandidate"
                return "$path\MSBuild\15.0\Bin\MSBuild.exe", "v141"
            }
        }

        if ($majorVersion -eq "14")
        {
            $clExe= "$path\VC\bin\cl.exe"
            if (Test-Path $clExe)
            {
                Write-Verbose "Picking: $instanceCandidate"
                $programFilesPath = getProgramFiles32bit
                return "$programFilesPath\MSBuild\14.0\Bin\MSBuild.exe", "v140"
            }
        }
    }

    throw "Could not find MSBuild version with C++ support. VS2015, VS2017, or VS2019 (with C++) needs to be installed."
}
function getWindowsSDK( [Parameter(Mandatory=$False)][switch]$DisableWin10SDK = $False,
                        [Parameter(Mandatory=$False)][switch]$DisableWin81SDK = $False,
                        [Parameter(Mandatory=$False)][string]$withWinSDK)
{
    if ($DisableWin10SDK -and $DisableWin81SDK)
    {
        throw "Both Win10SDK and Win81SDK were disabled."
    }

    Write-Verbose "Finding WinSDK"

    $validInstances = New-Object System.Collections.ArrayList

    # Windows 10 SDK
    function CheckWindows10SDK($path)
    {
        if ($null -eq $path)
        {
            return
        }

        $folder = (Join-Path $path "Include")
        if (!(Test-Path $folder))
        {
            Write-Verbose "$folder - Not Found"
            return
        }

        Write-Verbose "$folder - Found"
        $win10sdkVersions = @(Get-ChildItem $folder | Where-Object {$_.Name -match "^10"} | Sort-Object)
        [array]::Reverse($win10sdkVersions) # Newest SDK first

        foreach ($win10sdkV in $win10sdkVersions)
        {
            $windowsheader = "$folder\$win10sdkV\um\windows.h"
            if (!(Test-Path $windowsheader))
            {
                Write-Verbose "$windowsheader - Not Found"
                continue
            }
            Write-Verbose "$windowsheader - Found"

            $ddkheader = "$folder\$win10sdkV\shared\sdkddkver.h"
            if (!(Test-Path $ddkheader))
            {
                Write-Verbose "$ddkheader - Not Found"
                continue
            }

            Write-Verbose "$ddkheader - Found"
            $win10sdkVersionString = $win10sdkV.ToString()
            Write-Verbose "Found $win10sdkVersionString"
            $validInstances.Add($win10sdkVersionString) > $null
        }
    }

    Write-Verbose "`n"
    Write-Verbose "Looking for Windows 10 SDK"
    $regkey10 = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows Kits\Installed Roots\' -Name 'KitsRoot10' -ErrorAction SilentlyContinue
    $regkey10Wow6432 = Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows Kits\Installed Roots\' -Name 'KitsRoot10' -ErrorAction SilentlyContinue
    if (vcpkgHasProperty -object $regkey10 "KitsRoot10") { CheckWindows10SDK($regkey10.KitsRoot10) }
    if (vcpkgHasProperty -object $regkey10Wow6432 "KitsRoot10") { CheckWindows10SDK($regkey10Wow6432.KitsRoot10) }
    CheckWindows10SDK("$env:ProgramFiles\Windows Kits\10")
    CheckWindows10SDK("${env:ProgramFiles(x86)}\Windows Kits\10")

    # Windows 8.1 SDK
    function CheckWindows81SDK($path)
    {
        if ($null -eq $path)
        {
            return
        }

        $folder = "$path\Include"
        if (!(Test-Path $folder))
        {
            Write-Verbose "$folder - Not Found"
            return
        }

        Write-Verbose "$folder - Found"
        $win81sdkVersionString = "8.1"
        Write-Verbose "Found $win81sdkVersionString"
        $validInstances.Add($win81sdkVersionString) > $null
    }

    Write-Verbose "`n"
    Write-Verbose "Looking for Windows 8.1 SDK"
    $regkey81 = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows Kits\Installed Roots\' -Name 'KitsRoot81' -ErrorAction SilentlyContinue
    $regkey81Wow6432 = Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows Kits\Installed Roots\' -Name 'KitsRoot81' -ErrorAction SilentlyContinue
    if (vcpkgHasProperty -object $regkey81 "KitsRoot81") { CheckWindows81SDK($regkey81.KitsRoot81) }
    if (vcpkgHasProperty -object $regkey81Wow6432 "KitsRoot81") { CheckWindows81SDK($regkey81Wow6432.KitsRoot81) }
    CheckWindows81SDK("$env:ProgramFiles\Windows Kits\8.1")
    CheckWindows81SDK("${env:ProgramFiles(x86)}\Windows Kits\8.1")

    Write-Verbose "`n`n`n"
    Write-Verbose "The following Windows SDKs were found:"
    foreach ($instance in $validInstances)
    {
        Write-Verbose $instance
    }

    # Selecting
    if ($withWinSDK -ne "")
    {
        foreach ($instance in $validInstances)
        {
            if ($instance -eq $withWinSDK)
            {
                return $instance
            }
        }

        throw "Could not find the requested Windows SDK version: $withWinSDK"
    }

    foreach ($instance in $validInstances)
    {
        if (!$DisableWin10SDK -and $instance -match "10.")
        {
            return $instance
        }

        if (!$DisableWin81SDK -and $instance -match "8.1")
        {
            return $instance
        }
    }

    throw "Could not detect a Windows SDK / TargetPlatformVersion"
}

$msbuildExeWithPlatformToolset = findAnyMSBuildWithCppPlatformToolset $withVSPath
$msbuildExe = $msbuildExeWithPlatformToolset[0]
$platformToolset = $msbuildExeWithPlatformToolset[1]
$windowsSDK = getWindowsSDK -withWinSDK $withWinSDK

$disableMetricsValue = "0"
if ($disableMetrics)
{
    $disableMetricsValue = "1"
}

$platform = "x86"
$vcpkgReleaseDir = "$vcpkgSourcesPath\msbuild.x86.release"
if($PSVersionTable.PSVersion.Major -le 2)
{ 
    $architecture=(Get-WmiObject win32_operatingsystem | Select-Object osarchitecture).osarchitecture
}
else
{
    $architecture=(Get-CimInstance win32_operatingsystem | Select-Object osarchitecture).osarchitecture
}
if ($win64)
{
    if (-not $architecture -like "*64*")
    {
        throw "Cannot build 64-bit on non-64-bit system"
    }

    $platform = "x64"
    $vcpkgReleaseDir = "$vcpkgSourcesPath\msbuild.x64.release"
}

if ($architecture -like "*64*")
{
    $PreferredToolArchitecture = "x64"
}
else
{
    $PreferredToolArchitecture = "x86"
}

$arguments = (
"`"/p:VCPKG_VERSION=-nohash`"",
"`"/p:DISABLE_METRICS=$disableMetricsValue`"",
"/p:Configuration=Release",
"/p:Platform=$platform",
"/p:PlatformToolset=$platformToolset",
"/p:TargetPlatformVersion=$windowsSDK",
"/p:PreferredToolArchitecture=$PreferredToolArchitecture",
"/verbosity:minimal",
"/m",
"/nologo",
"`"$vcpkgSourcesPath\dirs.proj`"") -join " "

function vcpkgInvokeCommandClean()
{
    param ( [Parameter(Mandatory=$true)][string]$executable,
                                        [string]$arguments = "")

    Write-Verbose "Clean-Executing: ${executable} ${arguments}"
    $scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
    $cleanEnvScript = "$scriptsDir\cleanEnvironmentHelper.ps1"
    $tripleQuotes = "`"`"`""
    $argumentsWithEscapedQuotes = $arguments -replace "`"", $tripleQuotes
    $command = ". $tripleQuotes$cleanEnvScript$tripleQuotes; & $tripleQuotes$executable$tripleQuotes $argumentsWithEscapedQuotes"
    $arg = "-NoProfile", "-ExecutionPolicy Bypass", "-command $command"

    $process = Start-Process -FilePath powershell.exe -ArgumentList $arg -PassThru -NoNewWindow
    Wait-Process -InputObject $process
    $ec = $process.ExitCode
    Write-Verbose "Execution terminated with exit code $ec."
    return $ec
}

# vcpkgInvokeCommandClean cmd "/c echo %PATH%"
Write-Host "`nBuilding vcpkg.exe ...`n"
$ec = vcpkgInvokeCommandClean $msbuildExe $arguments

if ($ec -ne 0)
{
    Write-Error "Building vcpkg.exe failed. Please ensure you have installed Visual Studio with the Desktop C++ workload and the Windows SDK for Desktop C++."
    return
}
Write-Host "`nBuilding vcpkg.exe... done.`n"

Write-Verbose "Placing vcpkg.exe in the correct location"

Copy-Item "$vcpkgReleaseDir\vcpkg.exe" "$vcpkgRootDir\vcpkg.exe"
Copy-Item "$vcpkgReleaseDir\vcpkgmetricsuploader.exe" "$vcpkgRootDir\scripts\vcpkgmetricsuploader.exe"
Remove-Item "$vcpkgReleaseDir" -Force -Recurse -ErrorAction SilentlyContinue
