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
"@ | Out-File -FilePath "$outputDir\$architecture-windows-$linkage-$vsInstallNickname.cmake" -Encoding ASCII
        }

        $linkage = "dynamic"
        @"
set(VCPKG_TARGET_ARCHITECTURE $architecture)
set(VCPKG_CRT_LINKAGE $linkage)
set(VCPKG_LIBRARY_LINKAGE $linkage)
set(VCPKG_VISUAL_STUDIO_PATH "$vsInstallPath")

set(VCPKG_CMAKE_SYSTEM_NAME WindowsStore)
set(VCPKG_CMAKE_SYSTEM_VERSION 10.0)
"@  | Out-File -FilePath "$outputDir\$architecture-uwp-$linkage-$vsInstallNickname.cmake" -Encoding ASCII

    }
#}