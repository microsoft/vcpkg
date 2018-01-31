
function Recipe
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)][String]$filepath,
        [Parameter(Mandatory=$true)][ScriptBlock]$Action
    )

    Write-Verbose "Starting recipe for $filepath"

    if(!(Test-Path $filepath))
    {
        Write-Verbose "Invoking recipe for $filepath"
        $Action.Invoke()
    }
    if(!(Test-Path $filepath))
    {
        throw "failed $filepath"
    }
}

function checkExit
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)][bool]$condition,
        [Parameter(Mandatory=$true)][String]$errorMessage
    )

    if (!$condition)
    {
        Write-Host "Error: $errorMessage"
        throw
    }
}

function DownloadAndUpdateVSInstaller
{
    $installerPath = "$scriptsDir\vs_Community.exe"
    Recipe $installerPath {
        Write-Host "Downloading VS Installer..."
        vcpkgDownloadFile "https://aka.ms/vs/15/release/vs_community.exe" $installerPath
        Write-Host "Downloading VS Installer... done."
    }

    Write-Host "Updating VS Installer..."
    $ec = vcpkgInvokeCommand $installerPath "--update --quiet --wait --norestart"
    checkExit ($ec -eq 0) "Updating VS installer... failed."
    Write-Host "Updating VS Installer... done."

    return $installerPath
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

    $installerPath = DownloadAndUpdateVSInstaller

    Write-Host "Installing Visual Studio..."
    $arguments = (
    "--installPath `"$installPath`"",
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

    $ec = vcpkgInvokeCommand $installerPath "$arguments"
    checkExit ($ec -eq 0) "Installing Visual Studio... failed."

    Write-Host "Installing Visual Studio... done."
}


function UnattendedVSupdate
{
    param(
        [Parameter(Mandatory=$true)][string]$installPath
    )

    $installerPath = DownloadAndUpdateVSInstaller

    Write-Host "Updating Visual Studio..."
    $arguments = (
    "update",
    "--installPath `"$installPath`"",
    "--quiet",
    "--wait",
    "--norestart") -join " "

    $ec = vcpkgInvokeCommand $installerPath "$arguments"
    checkExit ($ec -eq 0) "Updating Visual Studio... failed."

    Write-Host "Updating Visual Studio... done."
}

# Constants
$VISUAL_STUDIO_2017_STABLE_PATH = "C:\VS2017\Stable"
$VISUAL_STUDIO_2017_UNSTABLE_PATH = "C:\VS2017\Unstable"

