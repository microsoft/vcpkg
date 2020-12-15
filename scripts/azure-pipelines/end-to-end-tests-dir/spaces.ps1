. $PSScriptRoot/../end-to-end-tests-prelude.ps1

##### Test spaces in the path
$CurrentTest = "zlib with spaces in path"
Write-Host $CurrentTest
./vcpkg install zlib "--triplet" $Triplet `
    "--no-binarycaching" `
    "--x-buildtrees-root=$TestingRoot/build Trees" `
    "--x-install-root=$TestingRoot/instalL ed" `
    "--x-packages-root=$TestingRoot/packaG es"
Throw-IfFailed
