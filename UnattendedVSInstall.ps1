[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$installPath,
    [Parameter(Mandatory=$true)][string]$nickname
)

# References
# https://docs.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio
# https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-community#desktop-development-with-c

$url = "https://aka.ms/vs/15/release/vs_community.exe"
$filename = "vs_Community.exe"

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

if (!(Test-Path $filename))
{
    Remove-Item "$filename.part" -Recurse -Force -ErrorAction SilentlyContinue
    Start-BitsTransfer -Source $url -Destination "$filename.part" -ErrorAction Stop
    Move-Item -Path "$filename.part" -Destination $filename -ErrorAction Stop
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

Invoke-Executable ".\$filename" "$arguments" -wait:$true
