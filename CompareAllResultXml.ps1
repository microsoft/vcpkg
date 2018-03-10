[CmdletBinding()]
param
(
    [Parameter(Mandatory=$true, Position=0)][string]$leftBuild,
    [Parameter(Mandatory=$true, Position=1)][string]$rightBuild
)

$myDir = split-path -parent $script:MyInvocation.MyCommand.Definition

$leftresults = ls \\vcpkg-000\General\Results\${leftBuild}_*.xml
$rightresults = ls \\vcpkg-000\General\Results\${rightBuild}_*.xml

Write-Verbose "Left results"
Write-Verbose "$leftresults"

Write-Verbose "Right results"
Write-Verbose "$rightresults"

$allresults = @($leftresults) + @($rightresults)

$groups = $allresults | % { $a = @($_.name -split "_", 2); New-Object PSObject -Property @{ "id"=$a[0]; "triplet"=$($a[1] -replace "(-dynamic)?(-stable|-unstable.*)?\.xml",""); "file"=$_ } } | group triplet

$groups

$groups | % {
    $_.Name
    if ($_.Count -ne 2)
    {
        "Not enough results: "+$($_.Group | % file)
    }
    else
    {
        & $myDir/CompareResultXml.ps1 $_.Group[0].file $_.Group[1].file
    }
}
