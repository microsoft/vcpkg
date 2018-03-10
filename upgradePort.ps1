[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)][String]$Port,
    [Parameter(Mandatory=$True)][String]$VcpkgPath,
    [Parameter(Mandatory=$True)][String]$WorkDirectory,
    [Parameter(Mandatory=$False)][Switch]$DryRun,
    [Parameter(Mandatory=$False)][Switch]$Releases,
    [Parameter(Mandatory=$False)][Switch]$Tags,
    [Parameter(Mandatory=$False)][Switch]$Rolling
)

if (!$Releases -and !$Tags -and !$Rolling)
{
    throw "Must pass releases, tags, or rolling"
}

if (!(Test-Path "$VcpkgPath/.vcpkg-root"))
{
    throw "Could not find $VcpkgPath/.vcpkg-root"
}

$portdir = "$VcpkgPath/ports/$Port"
$portfile = "$portdir/portfile.cmake"

$portfile_contents = Get-Content $portfile -Raw

$vcpkg_from_github_invokes = @($portfile_contents | select-string $(@("vcpkg_from_github\([^)]*",
"REPO +`"?([^)\s]+)[^)\S`"]+",
"REF +([^)\s]+)[^)\S]+",
"[^)]*\)") -join "") | % Matches)

if ($vcpkg_from_github_invokes.Count -eq 0)
{
    "$Port not upgraded: no call to vcpkg_from_github()"
    return
}

$repo = $vcpkg_from_github_invokes[0].Groups[1].Value -replace "`"",""
Write-Verbose "repo=$repo"
$oldtag = $vcpkg_from_github_invokes[0].Groups[2].Value -replace "`"",""
Write-Verbose "oldtag=$oldtag"

if ($Tags)
{
    $workdirarg = "--git-dir=$WorkDirectory/$repo.git"
    if (!(Test-Path "$WorkDirectory/$repo.git"))
    {
        git clone --bare https://github.com/$repo "$WorkDirectory/$repo.git"
    }
    else
    {
        git $workdirarg fetch --tags
    }
    $latesttagsha = git $workdirarg rev-list --tags --max-count=1
    $newtag = git $workdirarg describe --tags --abbrev=0 $latesttagsha
}
else
{
    try
    {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        if ($Releases)
        {
            $doc = Invoke-WebRequest -Uri "https://api.github.com/repos/$repo/releases/latest" | ConvertFrom-Json
            $newtag = $doc | % tag_name
            if (!$newtag)
            {
                "$Port not upgraded: no releases"
                return
            }
        }
        else
        {
            $doc = Invoke-WebRequest -Uri "https://api.github.com/repos/$repo/branches/master" | ConvertFrom-Json
            $newtag = $doc.commit.sha
        }
        Write-Verbose "newtag=$newtag"
    }
    catch [System.Net.WebException]
    {
        "unable to fetch for $Port"
        return
    }
}

if (!$newtag)
{
    "$Port not upgraded: calculating newtag failed"
    return
}

if ($newtag -ne $oldtag)
{
    Write-Verbose "Replacing"
    $filename = $($repo -replace "/","-") + "-$newtag.tar.gz"
    $downloaded_filename = "$VcpkgPath/downloads/$filename" -replace "\\","/"
    Write-Verbose "Archive path is $downloaded_filename"

    if (!(Test-Path "$VcpkgPath/downloads/$filename"))
    {
        Write-Verbose "Downloading"
        "file(DOWNLOAD `"https://github.com/$repo/archive/$newtag.tar.gz`" `"$downloaded_filename`")" | out-file -enc ascii temp.cmake
        cmake -P temp.cmake
    }
    $sha = $(cmake -E sha512sum "$downloaded_filename") -replace " .*",""
    Write-Verbose "SHA512=$sha"

    $oldcall = $vcpkg_from_github_invokes[0].Groups[0].Value
    $newcall = $oldcall -replace "REF[\s]+$oldtag","REF $newtag" -replace "SHA512[\s]+[^)\s]+","SHA512 $sha"
    Write-Verbose "oldcall is $oldcall"
    Write-Verbose "newcall is $newcall"
    $new_portfile_contents = $portfile_contents -replace [regex]::escape($oldcall),$newcall

    $libname = $repo -replace ".*/", ""
    Write-Verbose "libname is $libname"

    $oldcontrol = Get-Content "$portdir/CONTROL" -Raw

    if ($Rolling)
    {
        $newtag_without_v = Get-Date -Format "yyyy-MM-dd"
    }
    else
    {
        $newtag_without_v = $newtag -replace "^v([\d])","`$1" -replace "^$libname-",""
    }
    Write-Verbose "processed newtag is $newtag_without_v"

    $newcontrol = $oldcontrol -replace "\nVersion:[^\n]*","`nVersion: $newtag_without_v"

    if($DryRun)
    {
        "# $portdir/CONTROL"
        $newcontrol
        "# $portfile"
        $new_portfile_contents
    }
    else
    {
        $new_portfile_contents | Out-File $portfile -encoding Ascii -NoNewline
        $newcontrol | Out-File "$portdir/CONTROL" -encoding Ascii -NoNewline
        "$Port upgraded: $oldtag -> $newtag"
    }
}
else
{
    "$Port is up-to-date: $oldtag -> $newtag"
}