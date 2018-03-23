[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)][String]$ProjectPath,
    [Parameter(Mandatory=$True)][String]$HeadersDatabase,
    [Parameter(Mandatory=$False)][Switch]$IncludeObjects,
    [Parameter(Mandatory=$False)][Switch]$PackageRefObjects
)

$ProjectPath = [IO.Path]::GetFullPath("$(pwd)/$ProjectPath")
$HeadersDatabase = [IO.Path]::GetFullPath("$(pwd)/$HeadersDatabase")

$headermap = @{}

gc $HeadersDatabase | % {
    $entry = $_.split(":",2)
    $file = $entry[1].ToLower() -replace "\\","/"
    if (!$headermap.ContainsKey($file))
    {
        $headermap.Add($file, $entry[0])
    }
    else
    {
        $headermap.Set_Item($file, $headermap[$file]+"|"+$entry[0])
    }
}

$objs = cmd /c "findstr /snipr /C:`"[ `t]*#[ `t]*include[ `t]*[<`"`"`"`"].*[>`"`"`"`"]`" `"$ProjectPath\*`"" | % {
    $cols = $_.split(":", 4)
    New-Object PSObject -Property @{
        "file"=$($cols[0] + ":" + $cols[1]);
        "line"=$cols[2];
        "includetext"=$cols[3];
        "include"=$($cols[3] -replace "^.*?[<`"](.*)[>`"]`$","`$1" -replace "\\","/").ToLower();
    }
}
if ($IncludeObjects) { $objs; return }
$refs = $objs | % {
    $obj = $_
    if ($headermap.ContainsKey($obj."include"))
    {
        $package = $headermap[$obj."include"]
        New-Object PSObject -Property @{ "ref"=$obj."file" + ":" + $obj."line"; "include"=$obj."include"; "package"=$package }
    }
}

if ($PackageRefObjects) { $refs; return }

$refs | group package
