[CmdletBinding()]
param(
    [string]$buildNumber,
    [string]$destinationRoot
)

function MyCopyItem
{
    param(
        [string]$fromPath,
        [string]$toPath
    )

    Write-Host "    Copying $fromPath to $toPath..."
    $time = Measure-Command {Copy-Item $fromPath $toPath -Recurse}
    $totalSeconds = $time.TotalSeconds
    Write-Host "    Copying done. Time Taken: $totalSeconds seconds"
}

$from = "\\vcfs\Builds\VS\feature_WinC\$buildnumber"
$to = $destinationRoot -replace "\\$" # Remove potential trailing backslash

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

# a = archive
# -t7z = type is 7z
# -mx3 = Fast compression mode. Chosen (instead of, for example, -mx9 = ultra) because of [compressed space]/[compression time] ratio
# -mmt = Enable multithreading
# -y = Yes to everything
Write-Host "Creating 7z..."
Remove-Item "$buildNumber.7z" -Force -ErrorAction SilentlyContinue
$time7z = Measure-Command {& .\7za.exe a -t7z "$buildNumber.7z" $to\* -mx3 -mmt -y}
$totalSeconds7z = $time7z.TotalSeconds
Write-Host "Creating 7z... done. Time Taken: $totalSeconds7z seconds"