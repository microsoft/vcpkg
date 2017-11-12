# function CreateTripletsForVS
# {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)][String]$vsInstallPath,
        [Parameter(Mandatory=$true)][String]$vsInstallNickname,
        [Parameter(Mandatory=$true)][String]$outputDir
    )

    $vsInstallPath = $vsInstallPath -replace "\\","/"
    $vsInstallNickname = $vsInstallNickname.ToLower()

    foreach ($architecture in @("x86", "x64"))
    {
        foreach ($linkage in @("dynamic", "static"))
        {
            @"
set(VCPKG_TARGET_ARCHITECTURE $architecture)
set(VCPKG_CRT_LINKAGE $linkage)
set(VCPKG_LIBRARY_LINKAGE $linkage)
set(VCPKG_VISUAL_STUDIO_PATH "$vsInstallPath")
"@ | Out-File -FilePath "$outputDir\$architecture-windows-$linkage-$vsInstallNickname" -Encoding ASCII
        }
    }
#}