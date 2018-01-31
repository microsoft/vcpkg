[CmdletBinding()]
param
(
    [Parameter(Mandatory=$true)]
    [String]$PAT,
    [Parameter(Mandatory=$true)]
    [String]$username,
    [Parameter(Mandatory=$true)]
    [String]$pass
)

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"
. "$scriptsDir\VcpkgPowershellUtils-Private.ps1"

# Power Settings (so machine does not go to sleep)
powercfg /SETACVALUEINDEX SCHEME_BALANCED SUB_SLEEP STANDBYIDLE 0

$unstablePath = $VISUAL_STUDIO_2017_UNSTABLE_PATH
Recipe $unstablePath {
    UnattendedVSinstall -installPath $unstablePath -nickname "Unstable"
}

$stablePath = $VISUAL_STUDIO_2017_STABLE_PATH
Recipe $stablePath {
    UnattendedVSinstall -installPath $stablePath -nickname "Stable"
}

Recipe "C:/Program Files/Microsoft MPI/Bin/mpiexec.exe" {
    Write-Host "Installing MSMPI"
    $msmpiSetupFilename = "$scriptsDir\msmpisetup.exe"
    Recipe $msmpiSetupFilename {
        vcpkgDownloadFile "https://download.microsoft.com/download/D/B/B/DBB64BA1-7B51-43DB-8BF1-D1FB45EACF7A/MSMpiSetup.exe" $msmpiSetupFilename
    }
    vcpkgInvokeCommand "$msmpiSetupFilename" "-force -unattend"
}

$vstsRoot = "C:\"
$vstsName = "vsts"
$vstsPath = "C:\vsts"
$vstsWorkPath = "$vstsPath\_work"

Recipe $vstsWorkPath {

    Recipe $vstsPath {

        $file = "$scriptsDir\vsts-agent-win7-x64-2.124.0.zip"

        Recipe $file {
            vcpkgDownloadFile "https://github.com/Microsoft/vsts-agent/releases/download/v2.124.0/vsts-agent-win7-x64-2.124.0.zip" $file
        }

        vcpkgExtractFile -file $file -destinationDir $vstsRoot -outFilename $vstsName
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
    "--windowsLogonAccount $username",
    "--windowsLogonPassword $pass",
    "--work $vstsWorkPath") -join " "

    vcpkgInvokeCommand "$vstsPath\config.cmd" "$configCmdArguments"

    Pop-Location
}

# Exclude working drive from Windows Defender
Add-MpPreference -ExclusionPath "C:\"

Restart-Computer