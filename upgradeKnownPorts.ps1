[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)][String]$VcpkgPath,
    [Parameter(Mandatory=$True)][String]$WorkDirectory,
    [Parameter(Mandatory=$False)][Switch]$NoReleases,
    [Parameter(Mandatory=$False)][Switch]$NoTags,
    [Parameter(Mandatory=$False)][Switch]$NoRolling
)

if (!(Test-Path "$VcpkgPath/.vcpkg-root"))
{
    throw "Could not find $VcpkgPath/.vcpkg-root"
}

$utilsdir = split-path -parent $script:MyInvocation.MyCommand.Definition

$releasePorts = @(
    "azure-storage-cpp",
    "assimp",
    "c-ares",
    # disabled due to slow update cadence. In the future, once they have passed our current ref (Jan 29, 2018), this can be reenabled.
    # "cartographer",
    "cgal",
    "chakracore",
    "cimg",
    "cpp-redis",
    "directxmesh",
    "directxtex",
    "directxtk",
    "discord-rpc",
    "doctest",
    "gdcm2",
    "glm",
    "libevent",
    "matio",
    "openblas",
    "plog",
    "rapidjson",
    "rocksdb",
    "spdlog",
    "wt",
    "wxwidgets",
    "yaml-cpp"
)

$tagPorts = @(
    "brynet",
    "cctz",
    "curl",
    "eastl",
    "eigen3",
    "expat",
    "fmt",
    #"folly",
    "gflags",
    "glog",
    "grpc",
    "gtest",
    "harfbuzz",
    "jsoncpp",
    "openal-soft",
    "protobuf",
    #"libffi",
    "libjpeg-turbo",
    "libogg",
    "libpng",
    "libsodium",
    "libuv",
    "libwebsockets",
    "lz4",
    "openjpeg",
    "sdl2",
    "sfml",
    "snappy",
    "tbb",
    "zziplib"
)

$rollingPorts = @(
    "abseil",
    "alac",
    #"angle",
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
    #"glslang",
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
    #"refprop-headers",
    "rs-core-lib",
    #"secp256k1",
    #"shaderc",
    #"spirv-tools",
    "stb",
    "thrift",
    "tiny-dnn",
    "torch-th",
    "unicorn-lib",
    "unicorn",
    "yara",
    "zeromq"
)

if (!$NoReleases)
{
    $releasePorts | % {
        & "$utilsdir/upgradePort.ps1" -VcpkgPath $VcpkgPath -WorkDirectory $WorkDirectory -Port $_ -Releases
    }
}

if (!$NoTags)
{
    $tagPorts | % {
        & "$utilsdir/upgradePort.ps1" -VcpkgPath $VcpkgPath -WorkDirectory $WorkDirectory -Port $_ -Tags
    }
}

if (!$NoRolling)
{
    $rollingPorts | % {
        & "$utilsdir/upgradePort.ps1" -VcpkgPath $VcpkgPath -WorkDirectory $WorkDirectory -Port $_ -Rolling
    }
}
