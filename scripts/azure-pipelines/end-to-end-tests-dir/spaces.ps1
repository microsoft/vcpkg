. $PSScriptRoot/../end-to-end-tests-prelude.ps1

##### Test spaces in the path
$Script:CurrentTest = "zlib with spaces in path"
Write-Host $Script:CurrentTest
./vcpkg install zlib "--triplet" $Triplet `
    "--no-binarycaching" `
    "--x-buildtrees-root=$TestingRoot/build Trees" `
    "--x-install-root=$TestingRoot/instalL ed" `
    "--x-packages-root=$TestingRoot/packaG es"
Throw-IfFailed
