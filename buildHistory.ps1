[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$port,
    [Parameter(Mandatory=$true)][string]$triplet
)

$logsDrive = @(net use | where { $_ -match "\\\\vcpkgstandard.file.core.windows.net\\logs" } | % { $_.substring(13,2) })
if ($logsDrive.length -eq 0)
{
    throw "Cannot locate drive mapped to \\vcpkgstandard.file.core.windows.net\logs"
}
$logsDrive = $logsDrive[0]

$a = @(ls $logsDrive\*_${triplet}.xml)
[array]::Reverse($a)
$a = $a | % { $_.fullname }

select-string -pattern "$port" -path $a
