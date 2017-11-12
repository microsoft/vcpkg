[CmdletBinding()]
param(
    [string]$buildNumber,
    [string]$destinationRoot
)

$from = "\\vcfs\Builds\VS\feature_WinC\$buildnumber"
$to = $destinationRoot


Write-Verbose "Copying x86ret"
Copy-Item "$from\binaries.x86ret\bin\i386" "$to\bin\HostX86\x86" -Recurse
Copy-Item "$from\binaries.x86ret\bin\x86_amd64" "$to\bin\HostX86\x64" -Recurse
Copy-Item "$from\binaries.x86ret\bin\x86_arm" "$to\bin\HostX86\arm" -Recurse

Write-Verbose "Copying amd64ret"
Copy-Item "$from\binaries.amd64ret\bin\amd64" "$to\bin\HostX64\x64" -Recurse
Copy-Item "$from\binaries.amd64ret\bin\amd64_x86" "$to\bin\HostX64\x86" -Recurse
Copy-Item "$from\binaries.amd64ret\bin\amd64_arm" "$to\bin\HostX64\arm" -Recurse

# Only copy files and directories that already exist in the VS installation.
Write-Verbose "Copying inc, atlmfc, lib"
Copy-Item "$from\binaries.x86ret\inc" "$to\include" -Recurse
Copy-Item "$from\binaries.x86ret\atlmfc" "$to\atlmfc" -Recurse
Copy-Item "$from\binaries.x86ret\lib\i386" "$to\lib\x86" -Recurse
Copy-Item "$from\binaries.amd64ret\lib\amd64" "$to\lib\x64" -Recurse

# a = archive
# -t7z = type is 7z
# -mx3 = Fast compression mode. Chosen (instead of for example -mx9 = ultra) because of compressed space/compression time ratio
# -mmt = Enable multithreading
Write-Verbose "Create 7z..."
& .\7za.exe a -t7z "$buildNumber.7z" $to\* -mx3 -mmt