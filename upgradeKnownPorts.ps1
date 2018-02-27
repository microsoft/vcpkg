[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)][String]$VcpkgPath,
    [Parameter(Mandatory=$False)][Switch]$NoNonRolling,
    [Parameter(Mandatory=$False)][Switch]$NoRolling
)

if (!(Test-Path "$VcpkgPath/.vcpkg-root"))
{
    throw "Could not find $VcpkgPath/.vcpkg-root"
}

$utilsdir = split-path -parent $script:MyInvocation.MyCommand.Definition

$ports = @(
    "azure-storage-cpp",
    "c-ares",
    # disabled due to slow update cadence. In the future, once they have passed our current ref (Jan 29, 2018), this can be reenabled.
    # "cartographer",
    "cctz",
    "cgal",
    "chakracore",
    "cimg",
    "cpp-redis",
    "directxmesh",
    "directxtex",
    "directxtk",
    "doctest",
    "gdcm2",
    "grpc",
    "libwebsockets",
    "matio",
    "rocksdb",
    "spdlog",
    "wt",
    "yaml-cpp"
)

$rollingPorts = @(
    "abseil",
    "alac",
    "angle",
    "args",
    "asmjit",
    "aurora",
    "breakpad",
    "butteraugli",
    "cccapstone",
    "clara",
    "ctemplate",
    "exiv2",
    "fdk-aac",
    "freetype-gl",
    "glslang",
    "guetzli",
    "jsonnet",
    "libharu",
    "libudis86",
    "lodepng",
    "luasocket",
    "ms-gsl",
    "msinttypes",
    "mujs",
    "nuklear",
    "picosha2",
    "piex",
    "re2",
    "refprop-headers",
    "rs-core-lib",
    "secp256k1",
    "shaderc",
    "spirv-tools",
    "thrift",
    "tiny-dnn",
    "torch-th",
    "unicorn-lib",
    "unicorn",
    "yara",
    "zeromq"
)

if (!$NoNonRolling)
{
    $ports | % {
        & "$utilsdir/upgradePort.ps1" -VcpkgPath $VcpkgPath -Port $_
    }
}

if (!$NoRolling)
{
    $rollingPorts | % {
        & "$utilsdir/upgradePort.ps1" -VcpkgPath $VcpkgPath -Port $_ -Rolling
    }
}
