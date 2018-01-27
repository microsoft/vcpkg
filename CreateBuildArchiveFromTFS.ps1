[CmdletBinding()]
param(
    [string]$destinationRoot = ".",
    [string]$tfsBranch = "WinC",
    [Parameter(ParameterSetName='SetLatest')]
    [switch]$latest,
    [Parameter(ParameterSetName='SetBuildNumber')]
    [string]$buildNumber
)

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"

function FormatElapsedTime([TimeSpan]$ts)
{
    if ($ts.TotalHours -ge 1)
    {
        return [string]::Format( "{0:N2} h", $ts.TotalHours);
    }

    if ($ts.TotalMinutes -ge 1)
    {
        return [string]::Format( "{0:N2} min", $ts.TotalMinutes);
    }

    if ($ts.TotalSeconds -ge 1)
    {
        return [string]::Format( "{0:N2} s", $ts.TotalSeconds);
    }

    if ($ts.TotalMilliseconds -ge 1)
    {
        return [string]::Format( "{0:N2} ms", $ts.TotalMilliseconds);
    }

    throw $ts
}

function MyCopyItem
{
    param(
        [string]$fromPath,
        [string]$toPath
    )

    Write-Host "    Copying $fromPath to $toPath..."
    $toPathPart = "$toPath.part"
    #     $time = Measure-Command {Copy-Item $fromPath $toPathPart -Recurse}
    $time = Measure-Command {& Robocopy.exe $fromPath $toPathPart /E /MT /LOG:"robocopylog.txt"}
    Move-Item -Path $toPathPart -Destination $toPath -ErrorAction Stop
    $formattedTime = FormatElapsedTime $time
    Write-Host "    Copying done. Time Taken: $formattedTime seconds"
}

function KeepMostRecentFiles
{
    param(
        [Parameter(Mandatory=$true)]$files,
        [int]$keepCount
    )

    $sortedfiles = $files | Sort-object LastWriteTime -Descending
    for ($i = $keepCount; $i -lt $sortedfiles.Count; $i++)
    {
        vcpkgRemoveItem $sortedfiles[$i]
    }
}

$destinationRoot = $destinationRoot -replace "\\$"  # Remove potential trailing backslash

if ($latest)
{
    $buildRoot = "\\vcfs\Builds\VS\feature_$tfsBranch"
    $buildNumber = Get-Content "$buildRoot\latest.txt"
}

$buildId = "$tfsBranch-$buildNumber"
$sevenZip = "$destinationRoot\$buildId.7z"
if (Test-Path $sevenZip)
{
    Write-Host "$buildId is already archived ($sevenZip)"
    return
}

$from = "$buildRoot\$buildNumber"
$to = "$destinationRoot\$buildId"

$toCompleted = "$to.copycompleted"

if (!(Test-Path $toCompleted))
{
    Remove-Item $to -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Copying x86ret"
    MyCopyItem  "$from\binaries.x86ret\bin\i386" "$to\bin\HostX86\x86"
    MyCopyItem  "$from\binaries.x86ret\bin\x86_amd64" "$to\bin\HostX86\x64"
    MyCopyItem  "$from\binaries.x86ret\bin\x86_arm" "$to\bin\HostX86\arm"

    Write-Host "Copying amd64ret"
    MyCopyItem  "$from\binaries.amd64ret\bin\amd64" "$to\bin\HostX64\x64"
    MyCopyItem  "$from\binaries.amd64ret\bin\amd64_x86" "$to\bin\HostX64\x86"
    MyCopyItem  "$from\binaries.amd64ret\bin\amd64_arm" "$to\bin\HostX64\arm"

    # Only copy files and directories that already exist in the VS installation.
    Write-Host "Copying inc, atlmfc, lib"
    MyCopyItem  "$from\binaries.x86ret\inc" "$to\include"
    MyCopyItem  "$from\binaries.x86ret\atlmfc" "$to\atlmfc"
    MyCopyItem  "$from\binaries.x86ret\lib\i386" "$to\lib\x86"
    MyCopyItem  "$from\binaries.amd64ret\lib\amd64" "$to\lib\x64"

    Move-Item -Path $to -Destination $toCompleted
}

$sevenZipPart = "$sevenZip.part"
Remove-Item $sevenZip -Force -ErrorAction SilentlyContinue # Redundant
Remove-Item $sevenZipPart -Force -ErrorAction SilentlyContinue
Write-Host "Creating 7z..."

# a = archive
# -t7z = type is 7z
# -mx<N> = Compression mode
# -mmt = Enable multithreading
# -y = Yes to everything
#
# Compression mode-relevant info:
# - Uncompressed Size = 6.15GB
# - mx0: Size=6.15GB, CompressionTime= 55.30s , DecompressionTime=37s
# - mx1: Size=1.22GB, CompressionTime= 1.40min, DecompressionTime=90s
# - mx3: Size=1.05GB, CompressionTime= 2.66min, DecompressionTime=76s
# - mx5: Size= 787MB, CompressionTime= 8.59min, DecompressionTime=64s
# - mx7: Size= 724MB, CompressionTime=11.26min, DecompressionTime=64s
# - mx9: Size= 675MB, CompressionTime=13.79min, DecompressionTime=59s
$time7z = Measure-Command {& .\7za.exe a -t7z $sevenZipPart $toCompleted\* -mx9 -mmt -y}
Move-Item -Path $sevenZipPart -Destination $sevenZip
$formattedTime7z = FormatElapsedTime $time7z
Write-Host "Creating 7z... done. Time Taken: $formattedTime7z seconds"

vcpkgRemoveItem $toCompleted

KeepMostRecentFiles (Get-ChildItem $destinationRoot) -keepCount 10