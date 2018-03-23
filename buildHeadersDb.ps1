[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)][String]$VcpkgPath,
    [Parameter(Mandatory=$True)][String]$WorkDirectory,
    [Parameter(Mandatory=$True)][String]$Archives,
    [Parameter(Mandatory=$False)][String]$ExistingLog
)

$WorkDirectory = Resolve-Path $WorkDirectory
$VcpkgPath = Resolve-Path $VcpkgPath
$Archives = Resolve-Path $Archives

if($ExistingLog) {
    $cidryrun = gc $ExistingLog
    if (!$?) { throw 0 }
} else {
    $cidryrun = & $VcpkgPath ci x64-windows --dry-run
    if (!$?) { throw 0 }
}

$hashes = $cidryrun | ? { $_ -match "[a-f0-9]{40}" } | % { $Matches[0] }

$Location = pwd

try
{
    $hashes | % {
        $expandedpath = "$WorkDirectory\$_"
        if (!(Test-Path $expandedpath))
        {
            $archivepath = "$Archives/$($_.substring(0,2))/$_.zip"
            if (!(Test-Path $archivepath)) {
                return
            }

            rm -r -force "$expandedpath.tmp" -erroraction silentlycontinue
            Expand-Archive $archivepath -DestinationPath "$expandedpath.tmp"
            mv "$expandedpath.tmp" "$expandedpath"
        }

        $packagename = @(findstr /ir "^Package:" $expandedpath\CONTROL)[0] -replace "^Package:\s+",""

        if (!(Test-Path $expandedpath/include)) { return }
        Set-Location $expandedpath/include
        ls $expandedpath/include -recurse -File | resolve-path -relative | % { "${packagename}:$($_.substring(2))" }
    }
}
finally
{
    Set-Location $Location
}
