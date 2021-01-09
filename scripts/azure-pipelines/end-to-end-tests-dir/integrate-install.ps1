if (-not $IsLinux -and -not $IsMacOS) {
    . $PSScriptRoot/../end-to-end-tests-prelude.ps1

    $env:VCPKG_BINARY_SOURCES="clear;default,read"
    $env:VCPKG_KEEP_ENV_VARS="VCPKG_KEEP_ENV_VARS;VCPKG_BINARY_SOURCES;VCPKG_FORCE_SYSTEM_BINARIES;VCPKG_DOWNLOADS;VCPKG_DEFAULT_BINARY_CACHE"

    # Test msbuild props and targets
    $Script:CurrentTest = "zlib:x86-windows msbuild scripts\testing\integrate-install\..."
    Write-Host $Script:CurrentTest
    ./vcpkg $commonArgs install zlib:x86-windows
    Throw-IfFailed
    foreach ($project in @("Project1", "NoProps")) {
        $Script:CurrentTest = "msbuild scripts\testing\integrate-install\$project.vcxproj"
        Write-Host $Script:CurrentTest
        ./vcpkg $commonArgs env "msbuild scripts\testing\integrate-install\$project.vcxproj /p:VcpkgRoot=$TestingRoot\ /p:IntDir=$TestingRoot\int\ /p:OutDir=$TestingRoot\out\ "
        Throw-IfFailed
        Remove-Item -Recurse -Force $TestingRoot\int
        Remove-Item -Recurse -Force $TestingRoot\out
    }

    $Script:CurrentTest = "zlib:x86-windows-static msbuild scripts\testing\integrate-install\..."
    Write-Host $Script:CurrentTest
    ./vcpkg $commonArgs install zlib:x86-windows-static
    Throw-IfFailed
    foreach ($project in @("VcpkgTriplet", "VcpkgTriplet2", "VcpkgUseStatic", "VcpkgUseStatic2")) {
        $Script:CurrentTest = "msbuild scripts\testing\integrate-install\$project.vcxproj"
        ./vcpkg $commonArgs env "msbuild scripts\testing\integrate-install\$project.vcxproj /p:VcpkgRoot=$TestingRoot\ /p:IntDir=$TestingRoot\int\ /p:OutDir=$TestingRoot\out\ "
        Throw-IfFailed
        Remove-Item -Recurse -Force $TestingRoot\int
        Remove-Item -Recurse -Force $TestingRoot\out
    }

    Require-FileNotExists $installRoot/x64-windows-static/include/zlib.h
    Require-FileNotExists $installRoot/x64-windows/include/zlib.h
    Require-FileExists $installRoot/x86-windows/include/zlib.h
    $Script:CurrentTest = "msbuild scripts\testing\integrate-install\VcpkgUseStaticManifestHost.vcxproj"
    $vcpkgExe = Resolve-Path vcpkg.exe
    ./vcpkg $commonArgs env "msbuild scripts\testing\integrate-install\VcpkgUseStaticManifestHost.vcxproj `"/p:_VcpkgExecutable=$vcpkgExe`" /p:VcpkgRoot=$PSScriptRoot\..\..\..\ /p:IntDir=$TestingRoot\int\ /p:OutDir=$TestingRoot\out\ /p:TestingVcpkgInstalledDir=$installRoot"
    Throw-IfFailed
    Require-FileExists $installRoot/x64-windows-static/include/zlib.h
    Require-FileNotExists $installRoot/x86-windows/include/zlib.h
}

