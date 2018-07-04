[CmdletBinding()]
param
(
    [Parameter(Mandatory=$true, Position=0)][string]$leftPath,
    [Parameter(Mandatory=$true, Position=1)][string]$rightPath,
    [switch]$regressions,
    [string[]]$explicitPorts
)

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

[xml]$left = Get-Content $leftPath
[xml]$right = Get-Content $rightPath

$leftPortsPassMap = toPassMap($left)
$rightPortsPassMap = toPassMap($right)

$keys = $leftPortsPassMap.keys + $rightPortsPassMap.keys | select -unique | sort-object

$differences = New-Object System.Collections.ArrayList
foreach ($key in $keys)
{
    $l = $leftPortsPassMap[$key]
    $r = $rightPortsPassMap[$key]

    if($regressions)
    {
        if ($r -eq "Pass" -and $l -eq "Fail")
        {
            $differences.add($key) > $null
        }
        elseif ($explicitPorts.contains($key))
        {
            $differences.add($key) > $null
        }
    }
    else
    {
        if ($l -ne $r)
        {
            $differences.add($key) > $null
        }
        elseif ($explicitPorts.contains($key))
        {
            $differences.add($key) > $null
        }
    }
}

$diffCount = $differences.Count
Write-Host "Number of differences found: $diffCount"
$title = "{0,40} : {1,20} VS {2,20}" -f "DiffsTable", $leftPath, $rightPath
Write-Host $title

foreach ($key in $differences)
{
    $l1 = $leftPortsPassMap[$key]
    $r1 = $rightPortsPassMap[$key]
    $string = "{0,40} : {1,20} VS {2,-20}" -f $key, $l1, $r1
    $string
}

# function top15($doc) { $doc.assemblies.assembly.collection.test | % { New-Object -TypeName PsObject -Property @{ Name = $($_.name); Time = $([int]($_.time)); Result = $_.result } } | ? result -match "fail" | sort time | select -last 15 | format-table }
# use as top15 $([xml](gc \\vcpkg-000\General\Results\1456324_arm-uwp.xml ))
