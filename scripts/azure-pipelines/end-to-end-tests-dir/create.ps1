. $PSScriptRoot/../end-to-end-tests-prelude.ps1

# Test vcpkg create
$Script:CurrentTest = "create zlib"
Write-Host $Script:CurrentTest
./vcpkg --x-builtin-ports-root=$TestingRoot/ports create zlib https://github.com/madler/zlib/archive/v1.2.11.tar.gz zlib-1.2.11.tar.gz
Throw-IfFailed

Require-FileExists "$TestingRoot/ports/zlib/portfile.cmake"
Require-FileExists "$TestingRoot/ports/zlib/vcpkg.json"
