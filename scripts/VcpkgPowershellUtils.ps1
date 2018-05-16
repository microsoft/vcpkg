function vcpkgHasProperty([Parameter(Mandatory=$true)][AllowNull()]$object, [Parameter(Mandatory=$true)]$propertyName)
{
    if ($object -eq $null)
    {
        return $false
    }

    return [bool]($object.psobject.Properties | Where-Object { $_.Name -eq "$propertyName"})
}

function getProgramFiles32bit()
{
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
}