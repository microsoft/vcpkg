[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [String]$Value
)

$sha256 = New-Object -TypeName System.Security.Cryptography.SHA256CryptoServiceProvider
$utf8 = New-Object -TypeName System.Text.UTF8Encoding
[System.BitConverter]::ToString($sha256.ComputeHash($utf8.GetBytes($Value)))
