[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$disableMetrics = "0"
)

$scriptsdir = split-path -parent $MyInvocation.MyCommand.Definition
$vcpkgRoot = Split-path $scriptsdir -Parent

$gitHash = git rev-parse HEAD
Write-Verbose("Git hash is " + $gitHash)
$gitStartOfHash = $gitHash.substring(0,6)
$vcpkgSourcesPath = "$vcpkgRoot\toolsrc"
Write-Verbose("vcpkg Path " + $vcpkgSourcesPath)

if (!(Test-Path $vcpkgSourcesPath))
{
    New-Item -ItemType directory -Path $vcpkgSourcesPath -force | Out-Null
}

try{
    pushd $vcpkgSourcesPath
    cmd /c "$env:VS140COMNTOOLS..\..\VC\vcvarsall.bat" x86 "&" msbuild "/p:VCPKG_VERSION=-$gitHash" "/p:DISABLE_METRICS=$disableMetrics" /p:Configuration=Release /p:Platform=x86 /m

    Write-Verbose("Placing vcpkg.exe in the correct location")

    Copy-Item $vcpkgSourcesPath\Release\vcpkg.exe $vcpkgRoot\vcpkg.exe | Out-Null
    Copy-Item $vcpkgSourcesPath\Release\vcpkgmetricsuploader.exe $vcpkgRoot\scripts\vcpkgmetricsuploader.exe | Out-Null
}
finally{
    popd
}
