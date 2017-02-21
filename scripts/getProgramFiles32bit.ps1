[CmdletBinding()]
param(

)

if (Test-Path env:PROGRAMFILES`(X86`))
{
    return ${env:PROGRAMFILES(X86)}
}

return ${env:PROGRAMFILES}