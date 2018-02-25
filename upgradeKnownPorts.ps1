[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)][String]$VcpkgPath,
    [Parameter(Mandatory=$False)][Switch]$NoRolling
)

if (!(Test-Path "$VcpkgPath/.vcpkg-root"))
{
    throw "Could not find $VcpkgPath/.vcpkg-root"
}

$utilsdir = split-path -parent $script:MyInvocation.MyCommand.Definition

$ports = @(
    "cpp-redis",
    "azure-storage-cpp",
    "doctest",
    "gdcm2",
    "grpc",
    "matio",
    "spdlog",
    "yaml-cpp",
    "rocksdb",
    "wt",
    "cctz",
    "chakracore",
    "directxmesh",
    "directxtex",
    "directxtk",
    "cartographer",
    "grpc"
)

$rollingPorts = @(
    "ms-gsl",
    "abseil"
)

$ports | % {
    & "$utilsdir/upgradePort.ps1" -VcpkgPath $VcpkgPath -Port $_
}

if (!$NoRolling)
{
    $rollingPorts | % {
        & "$utilsdir/upgradePort.ps1" -VcpkgPath $VcpkgPath -Port $_ -Rolling
    }
}
