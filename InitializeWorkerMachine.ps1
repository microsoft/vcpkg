[CmdletBinding()]
param
(
    [Parameter(Mandatory=$true)]
    [String]$PAT,
    [Parameter(Mandatory=$true)]
    [String]$adminPass
)

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition

function Recipe
{
    [CmdletBinding()]
    param
    (
        [String]$filepath,
        [ScriptBlock]$Action
    )

    Write-Verbose "Starting recipe for $filepath"

    if(!(Test-Path $filepath))
    {
        Write-Verbose "Invoking recipe for $filepath"
        $Action.Invoke()
    }
    if(!(Test-Path $filepath))
    {
        throw "failed"
    }
}

function Invoke-Executable()
{
    param ( [Parameter(Mandatory=$true)][string]$executable,
                                        [string]$arguments = "",
                                        [switch]$wait)

    Write-Verbose "Executing: ${executable} ${arguments}"
    $process = Start-Process -FilePath $executable -ArgumentList $arguments -PassThru
    if ($wait)
    {
        Wait-Process -InputObject $process
        $ec = $process.ExitCode
        Write-Verbose "Execution terminated with exit code $ec."
    }
}

function DownloadFile([Parameter(Mandatory=$true)][string]$url, [Parameter(Mandatory=$true)][string]$filename)
{
    Remove-Item "$filename.part" -Recurse -Force -ErrorAction SilentlyContinue
    Start-BitsTransfer -Source $url -Destination "$filename.part" -ErrorAction Stop
    Move-Item -Path "$filename.part" -Destination $filename -ErrorAction Stop
}

function UnattendedVSinstall
{
    param(
        [Parameter(Mandatory=$true)][string]$installPath,
        [Parameter(Mandatory=$true)][string]$nickname
    )

    # References
    # https://docs.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio
    # https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-community#desktop-development-with-c

    $filename = "vs_Community.exe"
    Recipe "$scriptsDir\$filename" {
        DownloadFile "https://aka.ms/vs/15/release/vs_community.exe" $filename
    }

    Write-Host "Updating VS Installer"
    Invoke-Executable ".\$filename" "--update --quiet --wait --norestart" -wait:$true

    Write-Host "Installing Visual Studio"
    $arguments = ("--installPath $installPath",
    "--add Microsoft.VisualStudio.Workload.NativeDesktop",
    "--add Microsoft.VisualStudio.Workload.Universal",
    "--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
    "--add Microsoft.VisualStudio.Component.VC.Tools.ARM",
    "--add Microsoft.VisualStudio.Component.VC.Tools.ARM64",
    "--add Microsoft.VisualStudio.Component.VC.ATL",
    "--add Microsoft.VisualStudio.Component.VC.ATLMFC",
    "--add Microsoft.VisualStudio.Component.Windows10SDK.16299.Desktop",
    "--add Microsoft.VisualStudio.Component.Windows10SDK.16299.UWP",
    "--add Microsoft.VisualStudio.Component.Windows10SDK.16299.UWP.Native",
    "--add Microsoft.VisualStudio.ComponentGroup.UWP.VC",
    "--add Microsoft.Component.VC.Runtime.OSSupport",
    "--nickname $nickname",
    "--quiet",
    "--wait",
    "--norestart") -join " "

    Invoke-Executable "$scriptsDir\$filename" "$arguments" -wait:$true
}

# Power Settings (so machine does not go to sleep)
powercfg /SETACVALUEINDEX SCHEME_BALANCED SUB_SLEEP STANDBYIDLE 0

# Enable Remote Desktop Connection
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

$unstablePath = "C:\VS2017\Unstable"
Recipe $unstablePath {
    UnattendedVSinstall -installPath $unstablePath -nickname "Unstable"
}

$stablePath = "C:\VS2017\Stable"
Recipe $stablePath {
    UnattendedVSinstall -installPath $stablePath -nickname "Stable"
}

Recipe "C:/Program Files/Microsoft MPI/Bin/mpiexec.exe"
{
    $msmpiSetupFilename = "$scriptsDir\msmpisetup.exe"
    Recipe $msmpiSetupFilename {
        DownloadFile "https://download.microsoft.com/download/D/B/B/DBB64BA1-7B51-43DB-8BF1-D1FB45EACF7A/MSMpiSetup.exe" $msmpiSetupFilename
    }
    Invoke-Executable "$scriptsDir\$msmpiSetupFilename" "-force -unattend" -wait:$true
}

$vstsPath = "C:\vsts"
$vstsWorkPath = "$vstsPath\_work"

Recipe $vstsWorkPath {

    Recipe $vstsPath {

        $file = "$scriptsDir\vsts-agent-win7-x64-2.124.0.zip"

        Recipe $file {
            $tmp = "$scriptsDir\vsts-agent-win7-x64-2.124.0.zip.tmp"
            $WC = New-Object System.Net.WebClient
            Remove-Item $tmp
            $WC.DownloadFile("https://github.com/Microsoft/vsts-agent/releases/download/v2.124.0/vsts-agent-win7-x64-2.124.0.zip", $tmp)
            Move-Item $tmp "$scriptsDir\vsts-agent-win7-x64-2.124.0.zip"
        }

        Microsoft.PowerShell.Archive\Expand-Archive -path $file -destinationpath $vstsPath -ErrorAction Stop

    }

    Push-Location $vstsPath
    $devDivUrl = "https://devdiv.visualstudio.com"
    $configCmdArguments = ( "--unattended",
    "--url $devDivUrl",
    "--auth pat",
    "--token $PAT",
    "--pool VCLSPool",
    "--acceptTeeEula",
    "--replace",
    "--runAsService",
    "--windowsLogonAccount Administrator",
    "--windowsLogonPassword $adminPass",
    "--work $vstsWorkPath") -join " "

    Invoke-Executable "$vstsPath\config.cmd" "$configCmdArguments" -wait:$true

    Pop-Location
}

# Exclude working drive from Windows Defender
Add-MpPreference -ExclusionPath "C:\"

Restart-Computer