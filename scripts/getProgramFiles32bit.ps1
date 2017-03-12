[CmdletBinding()]
param(

)

$out = ${env:PROGRAMFILES(X86)}
if ($out -eq $null)
{
    $out = ${env:PROGRAMFILES}
}

if ($out -eq $null)
{
    throw "Could not find [Program Files 32-bit]"
}

return $out