[CmdletBinding()]
param(

)

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition
$programFiles32 = & $scriptsDir\getProgramFiles32bit.ps1
$programFilesP = & $scriptsDir\getProgramFilesPlatformBitness.ps1
$CandidateProgramFiles = $programFiles32, $programFilesP

# Windows 10 SDK
foreach ($ProgramFiles in $CandidateProgramFiles)
{
    $folder = "$ProgramFiles\Windows Kits\10\Include"
    if (!(Test-Path $folder))
    {
        continue
    }

    $win10sdkVersions = @(Get-ChildItem $folder | Where-Object {$_.Name -match "^10"} | Sort-Object)
    [array]::Reverse($win10sdkVersions) # Newest SDK first

    foreach ($win10sdkV in $win10sdkVersions)
    {
        if (Test-Path "$folder\$win10sdkV\um\windows.h")
        {
            return $win10sdkV.ToString()
        }
    }
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