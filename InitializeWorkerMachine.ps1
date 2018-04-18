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
Write-Host "Configuring power settings and pagefile..."
powercfg /SETACVALUEINDEX SCHEME_BALANCED SUB_SLEEP STANDBYIDLE 0
powercfg /h off

wmic computersystem set AutomaticManagedPagefile=False
wmic pagefileset delete
Write-Host "Configuring power settings and pagefile... done."

$unstablePath = $VISUAL_STUDIO_2017_UNSTABLE_PATH
Recipe $unstablePath {
    UnattendedVSinstall -installPath $unstablePath -nickname "Unstable"
}

$stablePath = $VISUAL_STUDIO_2017_STABLE_PATH
Recipe $stablePath {
    UnattendedVSinstall -installPath $stablePath -nickname "Stable"
}

Recipe "C:/Program Files/Microsoft MPI/Bin/mpiexec.exe" {
    Write-Host "Installing MSMPI..."
    $msmpiSetupFilename = "$scriptsDir\msmpisetup.exe"
    Recipe $msmpiSetupFilename {
        vcpkgDownloadFile "https://download.microsoft.com/download/2/E/C/2EC96D7F-687B-4613-80F6-E10F670A2D97/msmpisetup.exe" $msmpiSetupFilename
    }
    $ec = vcpkgInvokeCommand "$msmpiSetupFilename" "-force -unattend"
    checkWarn ($ec -eq 0) "Installing MSMPI... failed."
    Write-Host "Installing MSMPI... done."
}

$vstsRoot = "C:\"
$vstsPath = "C:\vsts"
$vstsWorkPath = "$vstsPath\_work"

Recipe $vstsWorkPath {

    Write-Host "Installing vsts-agent..."

    Recipe $vstsPath {

        $file = "$scriptsDir\vsts-agent-win7-x64-2.124.0.zip"

        Recipe $file {
            vcpkgDownloadFile "https://github.com/Microsoft/vsts-agent/releases/download/v2.124.0/vsts-agent-win7-x64-2.124.0.zip" $file
        }

        vcpkgExtractFile -archivePath $file -destinationDir $vstsRoot
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

    $ec = vcpkgInvokeCommand "$vstsPath\config.cmd" "$configCmdArguments"
    checkWarn ($ec -eq 0) "Installing vsts-agent... failed."

    Pop-Location
    Write-Host "Installing vsts-agent... done."
}

# Exclude working drive from Windows Defender
Write-Host "Configuring Windows Defender..."
Add-MpPreference -ExclusionPath "C:\"
Write-Host "Configuring Windows Defender... done."

Restart-Computer -Force