[CmdletBinding()]
param(

)

if (Test-Path env:ProgramW6432)
{
    return ${env:ProgramW6432}
}

return ${env:PROGRAMFILES}