[CmdletBinding()]
param
(
    [Parameter(Mandatory=$true, Position=0)][string[]]$leftBuild,
    [Parameter(Mandatory=$false, Position=1)][string[]]$rightBuild,
    [switch]$regressions,
    [string[]]$explicitPorts = @()
)

$logsDrive = @(net use | where { $_ -match "\\\\vcpkgstandard.file.core.windows.net\\logs" } | % { $_.substring(13,2) })
if ($logsDrive.length -eq 0)
{
    throw "Cannot locate drive mapped to \\vcpkgstandard.file.core.windows.net\logs"
}
$logsDrive = $logsDrive[0]

$myDir = split-path -parent $script:MyInvocation.MyCommand.Definition

$leftresults = $leftBuild | % {
    ls \\vcpkg-000.redmond.corp.microsoft.com\General\Results\${_}_*.xml -erroraction silentlycontinue
    ls $logsDrive\${_}_*.xml -erroraction silentlycontinue
}
if ($rightBuild.count -eq 0)
{
    $rightBuild = & $myDir\baseline.ps1
}

$rightresults = $rightBuild | % {
    ls \\vcpkg-000.redmond.corp.microsoft.com\General\Results\${_}_*.xml -erroraction silentlycontinue
    ls $logsDrive\${_}_*.xml -erroraction silentlycontinue
}

Write-Verbose "Left results"
Write-Verbose "$leftresults"

Write-Verbose "Right results"
Write-Verbose "$rightresults"

Write-Verbose "$leftBuild=left"
Write-Verbose "$rightBuild=right"

$allresults = @($leftresults) + @($rightresults)

$groups = $allresults | % { $a = @($_.name -split "_"); New-Object PSObject -Property @{ "id"=$a[0]; "triplet"=$($a[-1] -replace "(-dynamic)?(-stable|-unstable.*)?\.xml",""); "file"=$_ } } | group triplet

$groups

$groups | % {
    $_.Name
    if ($_.Count -ne 2)
    {
        "Not enough results: "+$($_.Group | % file)
    }
    else
    {
        if ($regressions)
        {
            & $myDir/CompareResultXml.ps1 $_.Group[0].file $_.Group[1].file -regressions -explicitPorts $explicitPorts
        }
        else
        {
            & $myDir/CompareResultXml.ps1 $_.Group[0].file $_.Group[1].file -explicitPorts $explicitPorts
        }
    }
}
