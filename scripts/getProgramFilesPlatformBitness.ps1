[CmdletBinding()]
param(

)

$out = ${env:ProgramW6432}
if ($out -eq $null)
{
    $out = ${env:PROGRAMFILES}
}

if ($out -eq $null)
{
    throw "Could not find [Program Files Platform Bitness]"
}

return $out