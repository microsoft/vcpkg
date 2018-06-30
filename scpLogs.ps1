[CmdletBinding()]
param()

$logsDrive = @(net use | where { $_ -match "\\\\vcpkgstandard.file.core.windows.net\\logs" } | % { $_.substring(13,2) })
if ($logsDrive.length -eq 0)
{
    throw "Cannot locate drive mapped to \\vcpkgstandard.file.core.windows.net\logs"
}
$logsDrive = $logsDrive[0]

scp -B ras0219@Roberts-Mini:/mnt/logs/*_x64-osx.xml $logsDrive\
if (!$?) { throw "failed" }
ssh ras0219@Roberts-Mini rm /mnt/logs/*_x64-osx.xml
if (!$?) { throw "failed" }
