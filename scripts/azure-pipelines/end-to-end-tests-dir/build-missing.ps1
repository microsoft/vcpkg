. $PSScriptRoot/../end-to-end-tests-prelude.ps1

$CurrentTest = "Build Missing tests"

Run-Vcpkg -TestArgs ($commonArgs + @("install", "rapidjson", "--only-binarycaching","--x-binarysource=clear;files,$ArchiveRoot,read"))
Throw-IfNotFailed
Require-FileNotExists "$installRoot/$Triplet/include/rapidjson/rapidjson.h"

# Create the rapidjson archive
Remove-Item -Recurse -Force $installRoot
Run-Vcpkg -TestArgs ($commonArgs + @("install", "rapidjson","--x-binarysource=clear;files,$ArchiveRoot,write"))
Throw-IfFailed
Require-FileExists "$installRoot/$Triplet/include/rapidjson/rapidjson.h"

Remove-Item -Recurse -Force $installRoot
Run-Vcpkg -TestArgs ($commonArgs + @("install", "rapidjson", "--only-binarycaching","--x-binarysource=clear;files,$ArchiveRoot,read"))
Throw-IfFailed
Require-FileExists "$installRoot/$Triplet/include/rapidjson/rapidjson.h"
