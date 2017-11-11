[CmdletBinding()]
param
(
    [Parameter(Mandatory=$true)]
    [String]$PAT,
    [Parameter(Mandatory=$true)]
    [String]$adminPassword
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

powercfg /SETACVALUEINDEX SCHEME_BALANCED SUB_SLEEP STANDBYIDLE 0

$filename = "vs_Community.exe"

Recipe "$scriptsDir\vs_Community.exe" {
    $url = "https://aka.ms/vs/15/release/vs_community.exe"

    Remove-Item "$filename.part" -Recurse -Force -ErrorAction SilentlyContinue
    Start-BitsTransfer -Source $url -Destination "$filename.part" -ErrorAction Stop
    Move-Item -Path "$filename.part" -Destination $filename -ErrorAction Stop
}

Recipe "C:\VS2017\Unstable" {
    & ".\$filename" --installPath "C:\VS2017\Unstable" `
    --add Microsoft.VisualStudio.Workload.NativeDesktop `
    --add Microsoft.VisualStudio.Workload.Universal `
    --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
    --add Microsoft.VisualStudio.Component.VC.Tools.ARM `
    --add Microsoft.VisualStudio.Component.VC.Tools.ARM64 `
    --add Microsoft.VisualStudio.Component.VC.ATL `
    --add Microsoft.VisualStudio.Component.VC.ATLMFC `
    --add Microsoft.Component.VC.Runtime.OSSupport `
    --add Microsoft.VisualStudio.Component.Windows10SDK.16299.Desktop `
    --add Microsoft.VisualStudio.Component.Windows10SDK.16299.UWP `
    --add Microsoft.VisualStudio.Component.Windows10SDK.16299.UWP.Native `
    --add Microsoft.Component.VC.Runtime.OSSupport `
    --add Microsoft.VisualStudio.ComponentGroup.UWP.VC `
    --nickname Unstable `
    --passive
}

Recipe "C:\VS2017\Stable" {
    & ".\$filename" --installPath "C:\VS2017\Stable" `
    --add Microsoft.VisualStudio.Workload.NativeDesktop `
    --add Microsoft.VisualStudio.Workload.Universal `
    --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
    --add Microsoft.VisualStudio.Component.VC.Tools.ARM `
    --add Microsoft.VisualStudio.Component.VC.Tools.ARM64 `
    --add Microsoft.VisualStudio.Component.VC.ATL `
    --add Microsoft.VisualStudio.Component.VC.ATLMFC `
    --add Microsoft.Component.VC.Runtime.OSSupport `
    --add Microsoft.VisualStudio.Component.Windows10SDK.16299.Desktop `
    --add Microsoft.VisualStudio.Component.Windows10SDK.16299.UWP `
    --add Microsoft.VisualStudio.Component.Windows10SDK.16299.UWP.Native `
    --add Microsoft.Component.VC.Runtime.OSSupport `
    --add Microsoft.VisualStudio.ComponentGroup.UWP.VC `
    --nickname Stable `
    --passive
}

Recipe "C:\vsts\_work" {

    Recipe "C:\vsts" {

        $file = "$scriptsDir\vsts-agent-win7-x64-2.124.0.zip"

        Recipe $file {
            $tmp = "$scriptsDir\vsts-agent-win7-x64-2.124.0.zip.tmp"
            $WC = New-Object System.Net.WebClient
            rm $tmp
            $WC.DownloadFile("https://github.com/Microsoft/vsts-agent/releases/download/v2.124.0/vsts-agent-win7-x64-2.124.0.zip", $tmp)
            mv $tmp "$scriptsDir\vsts-agent-win7-x64-2.124.0.zip"
        }

        Microsoft.PowerShell.Archive\Expand-Archive -path $file -destinationpath "C:\vsts" -ErrorAction Stop

    }

    pushd "C:\vsts"

    & ".\config.cmd" `
    --unattended `
    --url "https://devdiv.visualstudio.com" `
    --auth pat `
    --token $PAT `
    --pool VCLSPool `
    --acceptTeeEula `
    --replace `
    --runAsService `
    --windowsLogonAccount Administrator `
    --windowsLogonPassword $adminPassword `
    --work "C:\vsts\_work"

    popd

}