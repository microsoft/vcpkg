[CmdletBinding()]
param(

)

Import-Module BitsTransfer

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition
$CandidateProgramFiles = "${env:PROGRAMFILES(X86)}", "${env:PROGRAMFILES}"

# Windows 10 SDK
foreach ($ProgramFiles in $CandidateProgramFiles)
{
    $folder = "$ProgramFiles\Windows Kits\10\Include"
    if (!(Test-Path $folder))
    {
        continue
    }

    $win10sdkVersions = Get-ChildItem $folder | Where-Object {$_.Name -match "^10"} | Sort-Object
    $win10sdkVersionCount = $win10sdkVersions.Length

    if ($win10sdkVersionCount -eq 0)
    {
        continue
    }

    return $win10sdkVersions[$win10sdkVersionCount - 1].ToString()
}



# Windows 8.1 SDK
foreach ($ProgramFiles in $CandidateProgramFiles)
{
    $folder = "$ProgramFiles\Windows Kits\8.1\Include"
    if (Test-Path $folder)
    {
        return "8.1"
    }
}

throw "Could not detect a Windows SDK / TargetPlatformVersion"