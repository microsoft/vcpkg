if (-not $IsLinux -and -not $IsMacOS) {
    . $PSScriptRoot/../end-to-end-tests-prelude.ps1

    # Test msbuild props and targets
    $Script:CurrentTest = "zlib:x86-windows-static msbuild scripts\testing\integrate-install\..."
    Write-Host $Script:CurrentTest
    ./vcpkg $commonArgs install zlib:x86-windows-static --x-binarysource=clear
    Throw-IfFailed
    foreach ($project in @("VcpkgTriplet", "VcpkgTriplet2", "VcpkgUseStatic", "VcpkgUseStatic2")) {
        $Script:CurrentTest = "msbuild scripts\testing\integrate-install\$project.vcxproj"
        ./vcpkg $commonArgs env "msbuild scripts\testing\integrate-install\$project.vcxproj /p:VcpkgRoot=$TestingRoot /p:IntDir=$TestingRoot\int\ /p:OutDir=$TestingRoot\out\ "
        Throw-IfFailed
        Remove-Item -Recurse -Force $TestingRoot\int
        Remove-Item -Recurse -Force $TestingRoot\out
    }
    $Script:CurrentTest = "zlib:x86-windows msbuild scripts\testing\integrate-install\..."
    Write-Host $Script:CurrentTest
    ./vcpkg $commonArgs install zlib:x86-windows --x-binarysource=clear
    Throw-IfFailed
    foreach ($project in @("Project1", "NoProps")) {
        $Script:CurrentTest = "msbuild scripts\testing\integrate-install\$project.vcxproj"
        Write-Host $Script:CurrentTest
        ./vcpkg $commonArgs env "msbuild scripts\testing\integrate-install\$project.vcxproj /p:VcpkgRoot=$TestingRoot /p:IntDir=$TestingRoot\int\ /p:OutDir=$TestingRoot\out\ "
        Throw-IfFailed
        Remove-Item -Recurse -Force $TestingRoot\int
        Remove-Item -Recurse -Force $TestingRoot\out
    }
}
