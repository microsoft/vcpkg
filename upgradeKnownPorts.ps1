[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)][String]$VcpkgPath,
    [Parameter(Mandatory=$True)][String]$WorkDirectory,
    [Parameter(Mandatory=$False)][Switch]$NoTags,
    [Parameter(Mandatory=$False)][Switch]$NoTagsRegex,
    [Parameter(Mandatory=$False)][Switch]$NoRolling
)

if (!(Test-Path "$VcpkgPath/.vcpkg-root"))
{
    throw "Could not find $VcpkgPath/.vcpkg-root"
}

$utilsdir = split-path -parent $script:MyInvocation.MyCommand.Definition

$tagPorts = @(
    "azure-storage-cpp",
    "azure-iot-sdk-c",
    "azure-c-shared-utility",
    "azure-uamqp-c",
    "azure-uhttp-c",
    "azure-umqtt-c",
    "assimp",
    "bitserializer",
    "brynet",
    "c-ares",
    "caf",
    # disabled due to slow update cadence. In the future, once they have passed our current ref (Jan 29, 2018), this can be reenabled.
    # "cartographer",
    "cctz",
    # Disabled due to tags moving. Reactivate after releases/CGAL-4.11.1
    #"cgal",
    "chakracore",
    "cimg",
    "cpp-redis",
    "curl",
    "directxmesh",
    "discord-rpc",
    "doctest",
    "eastl",
    "eigen3",
    "expat",
    "fmt",
    #"folly",
    "gdcm2",
    "gflags",
    "glog",
    "grpc",
    "gtest",
    "harfbuzz",
    "jsoncpp",
    "openal-soft",
    "protobuf",
    "libevent",
    #"libffi",
    "libjpeg-turbo",
    "libogg",
    "libsodium",
    "libuv",
    "libwebsockets",
    "libzip",
    "lz4",
    "matio",
    "mpark-variant",
    "openblas",
    "openjpeg",
    "plog",
    "rapidjson",
    "rocksdb",
    "sdl2",
    "sfml",
    "snappy",
    "spdlog",
    "sqlite-orm",
    "uwebsockets",
    "wt",
    "yaml-cpp",
    "zziplib"
)

$tagPortsWithRegex = @(
    (New-Object PSObject -Property @{ "port"="libpng"; "regex"="v[\d\.]+`$" }),
    (New-Object PSObject -Property @{ "port"="glm"; "regex"="^[\d\.]+`$" }),
    (New-Object PSObject -Property @{ "port"="wxwidgets"; "regex"="v3.1" }),
    (New-Object PSObject -Property @{ "port"="libmysql"; "regex"="^mysql-[\d\.]+$" }),
    (New-Object PSObject -Property @{ "port"="tbb"; "regex"="^[\d]+_" }),
    (New-Object PSObject -Property @{ "port"="openimageio"; "regex"="^Release-" }),

    (New-Object PSObject -Property @{ "port"="directxtex"; "regex"="^[^\d]+\d+[^\d]?$" }),
    (New-Object PSObject -Property @{ "port"="directxtk"; "regex"="^[^\d]+\d+[^\d]?$" })
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
    "parson",
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
    #"yara",
    "zeromq"
)

if (!$NoTags)
{
    $tagPorts | % {
        & "$utilsdir/upgradePort.ps1" -VcpkgPath $VcpkgPath -WorkDirectory $WorkDirectory -Port $_ -Tags
    }
}

if (!$NoTagsRegex)
{
    $tagPortsWithRegex | % {
        & "$utilsdir/upgradePort.ps1" -VcpkgPath $VcpkgPath -WorkDirectory $WorkDirectory -Port $_.port -Regex $_.regex -Tags
    }
}

if (!$NoRolling)
{
    $rollingPorts | % {
        & "$utilsdir/upgradePort.ps1" -VcpkgPath $VcpkgPath -WorkDirectory $WorkDirectory -Port $_ -Rolling
    }
}
