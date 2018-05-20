[CmdletBinding()]
param
(
    [Parameter(Mandatory=$true)][string[]]$Builds
)

$myDir = split-path -parent $script:MyInvocation.MyCommand.Definition

$xmls = @($Builds | % { ls \\vcpkg-000.redmond.corp.microsoft.com\General\Results\${_}_*.xml })

$groups = $xmls | % { $a = @($_.name -split "_", 2); New-Object PSObject -Property @{ "id"=$a[0]; "triplet"=$($a[1] -replace "(-dynamic)?(-stable|-unstable.*)?\.xml",""); "file"=$_ } } | group triplet

function toPassMap([xml]$asText)
{
    $ports = @{}
    foreach($entry in $asText.assemblies.assembly.collection.test)
    {
        $name = $entry.name.substring(0, $entry.name.indexOf(':'))
        $ports.add($name, $entry.result)
    }

    return $ports
}

$groups | % {
    $group = $_
    $triplet = $_.Group[0].triplet
    if ($_.Count -ne 1)
    {
        Write-Verbose "Too many results: "+$($_.Group | % file)
    }
    else
    {
        [xml]$data = gc $_.Group[0].file
        $data.assemblies.assembly.collection.test | % {
            $name = ${_}.name.substring(0, $_.name.indexOf(':'))
            New-Object PSObject -Property @{
                "name"=$name;
                "triplet"=$triplet;
                "result"=$_.result
            }
        }
    }
} | group name | % {
    $obj = @{ "name"=$_.Group[0].name }
    $_.Group | % {
        $obj.add($_.triplet, $_.result)
    }
    New-Object PSObject -Property $obj
} 
