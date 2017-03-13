[CmdletBinding()]
param(
    [Parameter(Mandatory=$False)]
    [switch]$DisableWin10SDK = $False,

    [Parameter(Mandatory=$False)]
    [switch]$DisableWin81SDK = $False
)

if ($DisableWin10SDK -and $DisableWin81SDK)
{
    throw "Both Win10SDK and Win81SDK were disabled."
}

Write-Verbose "Executing $($MyInvocation.MyCommand.Name)"
$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition

$validInstances = New-Object System.Collections.ArrayList

$CandidateProgramFiles = $(& $scriptsDir\getProgramFiles32bit.ps1), $(& $scriptsDir\getProgramFilesPlatformBitness.ps1)
Write-Verbose "Program Files Candidate locations: $([system.String]::Join(',', $CandidateProgramFiles))"

# Windows 10 SDK
Write-Verbose "`n"
Write-Verbose "Looking for Windows 10 SDK"
foreach ($ProgramFiles in $CandidateProgramFiles)
{
    $folder = "$ProgramFiles\Windows Kits\10\Include"
    if (!(Test-Path $folder))
    {
        Write-Verbose "$folder - Not Found"
        continue
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
        $win10sdkVersionString = $win10sdkV.ToString()
        Write-Verbose "Found $win10sdkVersionString"
        $validInstances.Add($win10sdkVersionString) > $null
    }
}

# Windows 8.1 SDK
Write-Verbose "`n"
Write-Verbose "Looking for Windows 8.1 SDK"
foreach ($ProgramFiles in $CandidateProgramFiles)
{
    $folder = "$ProgramFiles\Windows Kits\8.1\Include"
    if (!(Test-Path $folder))
    {
        Write-Verbose "$folder - Not Found"
        continue
    }

    Write-Verbose "$folder - Found"
    $win81sdkVersionString = "8.1"
    Write-Verbose "Found $win81sdkVersionString"
    $validInstances.Add($win81sdkVersionString) > $null
}

Write-Verbose "`n`n`n"
Write-Verbose "The following Windows SDKs were found:"
foreach ($instance in $validInstances)
{
    Write-Verbose $instance
}

# Selecting
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