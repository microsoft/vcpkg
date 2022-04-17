[CmdletBinding()]
param (
    $libraries = @(),
    $version = "1.79.0",
    $portsDir = $null
)

$ErrorActionPreference = 'Stop'

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition
if ($null -eq $portsDir) {
    $portsDir = "$scriptsDir/../../ports"
}

if ($IsWindows) {
    $vcpkg = "$scriptsDir/../../vcpkg.exe"
    $curl = "curl.exe"
}
else {
    $vcpkg = "$scriptsDir/../../vcpkg"
    $curl = "curl"
}

# Clear this array when moving to a new boost version
$portVersions = @{
    #e.g. "boost-asio" = 1;
}

$portData = @{
    "boost"                  = @{
        "features" = @{
            "mpi" = @{
                "description"  = "Build with MPI support";
                "dependencies" = @("boost-mpi", "boost-graph-parallel", "boost-property-map-parallel");
            }
        }
    };
    "boost-asio"             = @{
        "features" = @{
            "ssl" = @{
                "description"  = "Build with SSL support";
                "dependencies" = @(@{ "name" = "openssl"; "platform" = "!emscripten" });
            }
        }
    };
    "boost-beast"            = @{ "supports" = "!emscripten" };
    "boost-fiber"            = @{
        "supports" = "!osx & !uwp & !arm & !emscripten";
        "features" = @{
            "numa" = @{
                "description" = "Enable NUMA support";
            }
        } 
    };
    "boost-filesystem"       = @{ "supports" = "!uwp" };
    "boost-iostreams"        = @{
        "default-features" = @("bzip2", "lzma", "zlib", "zstd");
        "supports"         = "!uwp";
        "features"         = @{
            "bzip2" = @{
                "description"  = "Support bzip2 filters";
                "dependencies" = @("bzip2");
            };
            "lzma"  = @{
                "description"  = "Support LZMA/xz filters";
                "dependencies" = @("liblzma");
            };
            "zlib"  = @{
                "description"  = "Support zlib filters";
                "dependencies" = @("zlib");
            };
            "zstd"  = @{
                "description"  = "Support zstd filters";
                "dependencies" = @("zstd");
            };
        };
    };
    "boost-context"          = @{ "supports" = "!uwp & !emscripten" };
    "boost-stacktrace"       = @{ "supports" = "!uwp" };
    "boost-coroutine"        = @{ "supports" = "!arm & !uwp & !emscripten" };
    "boost-coroutine2"       = @{ "supports" = "!emscripten" };
    "boost-test"             = @{ "supports" = "!uwp" };
    "boost-wave"             = @{ "supports" = "!uwp" };
    "boost-log"              = @{ "supports" = "!uwp & !emscripten" };
    "boost-locale"           = @{
        "dependencies" = @(@{ "name" = "libiconv"; "platform" = "!uwp & !windows & !mingw" });
        "supports"     = "!uwp";
        "features"     = @{
            "icu" = @{
                "description"  = "ICU backend for Boost.Locale";
                "dependencies" = @("icu");
            }
        }
    };
    "boost-mpi"              = @{
        "dependencies" = @("mpi");
        "supports"     = "!uwp";
        "features"     = @{
            "python3" = @{
                "description"  = "Build Python3 bindings";
                "supports"     = "!static";
                "dependencies" = @(@{ "name" = "boost-python"; "features" = @( "python3" ); "platform" = "!uwp & !emscripten & !ios & !android" }, "python3");
            }
        }
    };
    "boost-graph-parallel"   = @{
        "dependencies" = @("mpi");
        "supports"     = "!uwp";
    };
    "boost-odeint"           = @{
        "features" = @{
            "mpi" = @{
                "description"  = "Support parallelization with MPI";
                "dependencies" = @("boost-mpi");
            }
        }
    };
    "boost-parameter-python" = @{ "supports" = "!emscripten" };
    "boost-process"          = @{ "supports" = "!emscripten" };
    "boost-python"           = @{
        "default-features" = @("python3");
        "supports"         = "!uwp & !emscripten & !ios & !android";
        "features"         = @{
            "python2" = @{
                "description"  = "Build with Python2 support";
                "supports"     = "!(arm & windows)";
                "dependencies" = @("python2");
            };
            "python3" = @{
                "description"  = "Build with Python3 support";
                "dependencies" = @("python3");
            }
        }
    };
    "boost-regex"            = @{
        "features" = @{
            "icu" = @{
                "description"  = "ICU backend for Boost.Regex";
                "dependencies" = @("icu");
            }
        }
    }
}

function GeneratePortName() {
    param (
        [string]$Library
    )
    "boost-" + ($Library -replace "_", "-")
}

function GeneratePortDependency() {
    param (
        [string]$Library
    )
    $portName = GeneratePortName $Library
    if ($portData.Contains($portName) -and $portData[$portName].Contains('supports')) {
        @{name = $portName; platform = $portData[$portName]['supports'] }
    }
    else {
        $portName
    }
}

function GeneratePortManifest() {
    param (
        [string]$PortName,
        [string]$Homepage,
        [string]$Description,
        [string]$License,
        $Dependencies = @()
    )
    $manifest = @{
        "name"        = $PortName
        "version"     = $version
        "homepage"    = $Homepage
        "description" = $Description
    }
    if ($License) {
        $manifest["license"] += $License
    }
    if ($portData.Contains($PortName)) {
        $manifest += $portData[$PortName]
    }
    if ($portVersions.Contains($PortName)) {
        $manifest["port-version"] = $portVersions[$PortName]
    }
    if ($Dependencies.Count -gt 0) {
        $manifest["dependencies"] += $Dependencies
    }
    # Remove from the dependencies the ports that are included in the feature dependencies
    if ($manifest.Contains('features') -and $manifest.Contains('dependencies')) {
        foreach ($feature in $manifest.features.Keys) {
            $feature_dependencies = $manifest.features.$feature["dependencies"]
            foreach ($dependency in $feature_dependencies) {
                if ($dependency.Contains("name")) {
                    $dep_name = $dependency.name
                }
                else {
                    $dep_name = $dependency
                }
                $manifest["dependencies"] = $manifest["dependencies"] `
                | Where-Object { 
                    if ($_.Contains("name")) {
                        $_.name -notmatch "$dep_name"
                    } else {
                        $_ -notmatch "$dep_name"
                    }
                }
            }
        }
    }

    $manifest | ConvertTo-Json -Depth 10 -Compress `
    | Out-File -Encoding UTF8 "$portsDir/$PortName/vcpkg.json"
    & $vcpkg format-manifest "$portsDir/$PortName/vcpkg.json"
}

function GeneratePort() {
    param (
        [string]$Library,
        [string]$Hash,
        [bool]$NeedsBuild,
        $Dependencies = @()
    )

    $portName = GeneratePortName $Library

    New-Item -ItemType "Directory" "$portsDir/$portName" -erroraction SilentlyContinue | out-null

    # Generate vcpkg.json
    GeneratePortManifest `
        -PortName $portName `
        -Homepage "https://github.com/boostorg/$Library" `
        -Description "Boost $Library module" `
        -License "BSL-1.0" `
        -Dependencies $Dependencies

    $portfileLines = @(
        "# Automatically generated by scripts/boost/generate-ports.ps1"
        ""
    )

    if ($Library -eq "system") {
        $portfileLines += @(
            "vcpkg_buildpath_length_warning(37)"
            ""
        )
    }

    $portfileLines += @(
        "vcpkg_from_github("
        "    OUT_SOURCE_PATH SOURCE_PATH"
        "    REPO boostorg/$Library"
        "    REF boost-$version"
        "    SHA512 $Hash"
        "    HEAD_REF master"
    )
    [Array]$patches = Get-Item -Path "$portsDir/$portName/*.patch"
    if ($null -eq $patches -or $patches.Count -eq 0) {
    }
    elseif ($patches.Count -eq 1) {
        $portfileLines += @("    PATCHES $($patches.name)")
    }
    else {
        $portfileLines += @("    PATCHES")
        foreach ($patch in $patches) {
            $portfileLines += @("        $($patch.name)")
        }
    }
    $portfileLines += @(
        ")"
        ""
    )

    if (Test-Path "$scriptsDir/post-source-stubs/$Library.cmake") {
        $portfileLines += @(Get-Content "$scriptsDir/post-source-stubs/$Library.cmake")
    }

    if ($NeedsBuild) {
        $portfileLines += @(
            "include(`${CURRENT_HOST_INSTALLED_DIR}/share/boost-build/boost-modular-build.cmake)"
        )
        # b2-options.cmake contains port-specific build options
        if (Test-Path "$portsDir/$portName/b2-options.cmake") {
            $portfileLines += @(
                "boost_modular_build("
                "    SOURCE_PATH `${SOURCE_PATH}"
                "    BOOST_CMAKE_FRAGMENT `"`${CMAKE_CURRENT_LIST_DIR}/b2-options.cmake`""
                ")"
            )
        }
        elseif (Test-Path "$portsDir/$portName/b2-options.cmake.in") {
            $portfileLines += @(
                'configure_file('
                '    "${CMAKE_CURRENT_LIST_DIR}/b2-options.cmake.in"'
                '    "${CURRENT_BUILDTREES_DIR}/vcpkg-b2-options.cmake"'
                '    @ONLY'
                ')'
                'boost_modular_build('
                '    SOURCE_PATH ${SOURCE_PATH}'
                '    BOOST_CMAKE_FRAGMENT "${CURRENT_BUILDTREES_DIR}/vcpkg-b2-options.cmake"'
                ')'
            )
        }
        else {
            $portfileLines += @(
                "boost_modular_build(SOURCE_PATH `${SOURCE_PATH})"
            )
        }
    }

    $portfileLines += @(
        "include(`${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)"
        "boost_modular_headers(SOURCE_PATH `${SOURCE_PATH})"
    )

    if (Test-Path "$scriptsDir/post-build-stubs/$Library.cmake") {
        $portfileLines += @(Get-Content "$scriptsDir/post-build-stubs/$Library.cmake")
    }

    $portfileLines += @("")
    Set-Content -LiteralPath "$portsDir/$portName/portfile.cmake" `
        -Value "$($portfileLines -join "`r`n")" `
        -Encoding UTF8 `
        -NoNewline
}

if (!(Test-Path "$scriptsDir/boost")) {
    "Cloning boost..."
    Push-Location $scriptsDir
    try {
        git clone https://github.com/boostorg/boost --branch boost-$version
    }
    finally {
        Pop-Location
    }
}
else {
    Push-Location $scriptsDir/boost
    try {
        git fetch
        git checkout -f boost-$version
    }
    finally {
        Pop-Location
    }
}

$foundLibraries = Get-ChildItem $scriptsDir/boost/libs -directory | ForEach-Object name | ForEach-Object {
    if ($_ -eq "numeric") {
        "numeric_conversion"
        "interval"
        "odeint"
        "ublas"
    }
    elseif ($_ -eq "headers") {
    }
    else {
        $_
    }
}

New-Item -ItemType "Directory" $scriptsDir/downloads -erroraction SilentlyContinue | out-null

$updateServicePorts = $false

if ($libraries.Length -eq 0) {
    $libraries = $foundLibraries
    $updateServicePorts = $true
}

$boostPortDependencies = @()

foreach ($library in $libraries) {
    "Handling boost/$library..."
    $archive = "$scriptsDir/downloads/$library-boost-$version.tar.gz"
    if (!(Test-Path $archive)) {
        "Downloading boost/$library..."
        & $curl -L "https://github.com/boostorg/$library/archive/boost-$version.tar.gz" --output "$scriptsDir/downloads/$library-boost-$version.tar.gz"
    }
    $hash = & $vcpkg --x-wait-for-lock hash $archive
    # remove prefix "Waiting to take filesystem lock on <path>/.vcpkg-root... "
    if ($hash -is [Object[]]) {
        $hash = $hash[1]
    }

    $unpacked = "$scriptsDir/libs/$library-boost-$version"
    if (!(Test-Path $unpacked)) {
        "Unpacking boost/$library..."
        New-Item -ItemType "Directory" $scriptsDir/libs -erroraction SilentlyContinue | out-null
        Push-Location $scriptsDir/libs
        try {
            cmake -E tar xf $archive
        }
        finally {
            Pop-Location
        }
    }
    Push-Location $unpacked
    try {
        $usedLibraries = Get-ChildItem -Recurse -Path include, src -File `
        | Where-Object { $_ -is [System.IO.FileInfo] } `
        | ForEach-Object {
            Write-Verbose "${library}: processing file: $_"
            Get-Content -LiteralPath $_
        } `
        | Where-Object {
            $_ -match ' *# *include *[<"]boost\/'
        } `
        | ForEach-Object {
            # extract path from the line
            Write-Verbose "${library}: processing line: $_"
            $_ -replace " *# *include *[<`"]boost\/([a-zA-Z0-9\.\-_\/]*)[>`"].*", "`$1"
        }`
        | ForEach-Object {
            # map the path to the library name
            Write-Verbose "${library}: processing path: $_"
            if ($_ -match "^detail\/winapi\/") { "winapi" }
            elseif ($_ -eq "detail/algorithm.hpp") { "graph" }
            elseif ($_ -eq "detail/atomic_count.hpp") { "smart_ptr" }
            elseif ($_ -eq "detail/basic_pointerbuf.hpp") { "lexical_cast" }
            elseif ($_ -eq "detail/call_traits.hpp") { "utility" }
            elseif ($_ -eq "detail/compressed_pair.hpp") { "utility" }
            elseif ($_ -eq "detail/interlocked.hpp") { "winapi" }
            elseif ($_ -eq "detail/iterator.hpp") { "core" }
            elseif ($_ -eq "detail/lcast_precision.hpp") { "lexical_cast" }
            elseif ($_ -eq "detail/lightweight_mutex.hpp") { "smart_ptr" }
            elseif ($_ -eq "detail/lightweight_test.hpp") { "core" }
            elseif ($_ -eq "detail/lightweight_thread.hpp") { "smart_ptr" }
            elseif ($_ -eq "detail/no_exceptions_support.hpp") { "core" }
            elseif ($_ -eq "detail/scoped_enum_emulation.hpp") { "core" }
            elseif ($_ -eq "detail/sp_typeinfo.hpp") { "core" }
            elseif ($_ -eq "detail/ob_compressed_pair.hpp") { "utility" }
            elseif ($_ -eq "detail/quick_allocator.hpp") { "smart_ptr" }
            elseif ($_ -eq "detail/workaround.hpp") { "config" }
            elseif ($_ -match "^functional\/hash\/") { "container_hash" }
            elseif ($_ -eq "functional/hash.hpp") { "container_hash" }
            elseif ($_ -eq "functional/hash_fwd.hpp") { "container_hash" }
            elseif ($_ -match "^graph\/distributed\/") { "graph_parallel" }
            elseif ($_ -match "^graph\/parallel\/") { "graph_parallel" }
            elseif ($_ -eq "graph/accounting.hpp") { "graph_parallel" }
            elseif ($_ -eq "exception/exception.hpp") { "throw_exception" }
            elseif ($_ -match "^numeric\/conversion\/") { "numeric_conversion" }
            elseif ($_ -match "^numeric\/interval\/") { "interval" }
            elseif ($_ -match "^numeric\/odeint\/") { "odeint" }
            elseif ($_ -match "^numeric\/ublas\/") { "ublas" }
            elseif ($_ -eq "numeric/interval.hpp") { "interval" }
            elseif ($_ -eq "numeric/odeint.hpp") { "odeint" }
            elseif ($_ -match "^parameter\/aux_\/python\/") { "parameter_python" }
            elseif ($_ -eq "parameter/python.hpp") { "parameter_python" }
            elseif ($_ -eq "pending/detail/disjoint_sets.hpp") { "graph" }
            elseif ($_ -eq "pending/detail/int_iterator.hpp") { "iterator" }
            elseif ($_ -eq "pending/detail/property.hpp") { "graph" }
            elseif ($_ -eq "pending/bucket_sorter.hpp") { "graph" }
            elseif ($_ -eq "pending/container_traits.hpp") { "graph" }
            elseif ($_ -eq "pending/disjoint_sets.hpp") { "graph" }
            elseif ($_ -eq "pending/fenced_priority_queue.hpp") { "graph" }
            elseif ($_ -eq "pending/fibonacci_heap.hpp") { "graph" }
            elseif ($_ -eq "pending/indirect_cmp.hpp") { "graph" }
            elseif ($_ -eq "pending/integer_log2.hpp") { "integer" }
            elseif ($_ -eq "pending/is_heap.hpp") { "graph" }
            elseif ($_ -eq "pending/iterator_adaptors.hpp") { "iterator" }
            elseif ($_ -eq "pending/iterator_tests.hpp") { "iterator" }
            elseif ($_ -eq "pending/mutable_heap.hpp") { "graph" }
            elseif ($_ -eq "pending/mutable_queue.hpp") { "graph" }
            elseif ($_ -eq "pending/property.hpp") { "graph" }
            elseif ($_ -eq "pending/property_serialize.hpp") { "graph" }
            elseif ($_ -eq "pending/queue.hpp") { "graph" }
            elseif ($_ -eq "pending/relaxed_heap.hpp") { "graph" }
            elseif ($_ -eq "pending/stringtok.hpp") { "graph" }
            elseif ($_ -match "^property_map\/parallel\/") { "property_map_parallel" }
            elseif ($_ -eq "utility/addressof.hpp") { "core" }
            elseif ($_ -eq "utility/declval.hpp") { "type_traits" }
            elseif ($_ -eq "utility/enable_if.hpp") { "core" }
            elseif ($_ -eq "utility/explicit_operator_bool.hpp") { "core" }
            elseif ($_ -eq "utility/swap.hpp") { "core" }
            # extract first directory name or file name from the path
            else { $_ -replace "([a-zA-Z0-9\.\-_]*).*", "`$1" }
        } `
        | ForEach-Object {
            # map directory/file name to the library name
            Write-Verbose "${library}: processing name: $_"
            if ($_ -eq "current_function.hpp") { "assert" }
            elseif ($_ -eq "memory_order.hpp") { "atomic" }
            elseif ($_ -match "is_placeholder.hpp|mem_fn.hpp") { "bind" }
            elseif ($_ -eq "circular_buffer_fwd.hpp") { "circular_buffer" }
            elseif ($_ -match "^concept$|concept_archetype.hpp") { "concept_check" }
            elseif ($_ -match "cstdint.hpp|cxx11_char_types.hpp|limits.hpp|version.hpp") { "config" }
            elseif ($_ -eq "contract_macro.hpp") { "contract" }
            elseif ($_ -match "implicit_cast.hpp|polymorphic_cast.hpp|polymorphic_pointer_cast.hpp") { "conversion" }
            elseif ($_ -eq "make_default.hpp") { "convert" }
            elseif ($_ -match "checked_delete.hpp|get_pointer.hpp|iterator.hpp|non_type.hpp|noncopyable.hpp|ref.hpp|swap.hpp|type.hpp|visit_each.hpp") { "core" }
            elseif ($_ -match "blank.hpp|blank_fwd.hpp|cstdlib.hpp") { "detail" }
            elseif ($_ -eq "dynamic_bitset_fwd.hpp") { "dynamic_bitset" }
            elseif ($_ -eq "exception_ptr.hpp") { "exception" }
            elseif ($_ -eq "foreach_fwd.hpp") { "foreach" }
            elseif ($_ -eq "function_equal.hpp") { "function" }
            elseif ($_ -match "integer_fwd.hpp|integer_traits.hpp") { "integer" }
            elseif ($_ -eq "io_fwd.hpp") { "io" }
            elseif ($_ -match "function_output_iterator.hpp|generator_iterator.hpp|indirect_reference.hpp|iterator_adaptors.hpp|next_prior.hpp|pointee.hpp|shared_container_iterator.hpp") { "iterator" }
            elseif ($_ -match "cstdfloat.hpp|math_fwd.hpp") { "math" }
            elseif ($_ -match "multi_index_container.hpp|multi_index_container_fwd.hpp") { "multi_index" }
            elseif ($_ -eq "cast.hpp") { "numeric_conversion" }
            elseif ($_ -match "none.hpp|none_t.hpp") { "optional" }
            elseif ($_ -eq "qvm_lite.hpp") { "qvm" }
            elseif ($_ -eq "nondet_random.hpp") { "random" }
            elseif ($_ -match "cregex.hpp|regex_fwd.hpp") { "regex" }
            elseif ($_ -eq "archive") { "serialization" }
            elseif ($_ -match "last_value.hpp|signal.hpp") { "signals" }
            elseif ($_ -match "enable_shared_from_this.hpp|intrusive_ptr.hpp|make_shared.hpp|make_unique.hpp|pointer_cast.hpp|pointer_to_other.hpp|scoped_array.hpp|scoped_ptr.hpp|shared_array.hpp|shared_ptr.hpp|weak_ptr.hpp") { "smart_ptr" }
            elseif ($_ -eq "cerrno.hpp") { "system" }
            elseif ($_ -eq "progress.hpp") { "timer" }
            elseif ($_ -match "token_functions.hpp|token_iterator.hpp") { "tokenizer" }
            elseif ($_ -match "aligned_storage.hpp") { "type_traits" }
            elseif ($_ -match "unordered_map.hpp|unordered_set.hpp") { "unordered" }
            elseif ($_ -match "call_traits.hpp|compressed_pair.hpp|operators.hpp|operators_v1.hpp") { "utility" }
            # by dafault use the name as is, just remove the file extension if available
            else { $_ -replace "\.hp?p?", "" }
        } `
        | Where-Object {
            $_ -ne $library
        } `
        | Group-Object -NoElement | ForEach-Object Name

        "      [known] " + $($usedLibraries | Where-Object { $foundLibraries -contains $_ })
        "    [unknown] " + $($usedLibraries | Where-Object { $foundLibraries -notcontains $_ })

        $deps = @($usedLibraries | Where-Object { $foundLibraries -contains $_ })
        # break unnecessary dependencies
        $deps = @($deps | ? {
            -not (
                ($library -eq 'gil' -and $_ -eq 'filesystem') # PR #20575
            )
        })
        $deps = @($deps | ForEach-Object { GeneratePortDependency $_ })
        $deps += @("boost-vcpkg-helpers")

        $needsBuild = $false
        if (((Test-Path $unpacked/build/Jamfile.v2) -or (Test-Path $unpacked/build/Jamfile)) -and $library -notmatch "function_types") {
            $deps += @(
                @{ name = "boost-build"; host = $True },
                @{ name = "boost-modular-build-helper"; host = $True },
                @{ name = "vcpkg-cmake"; host = $True }
            )
            $needsBuild = $true
        }

        GeneratePort `
            -Library $library `
            -Hash $hash `
            -Dependencies $deps `
            -NeedsBuild $needsBuild

        $boostPortDependencies += @(GeneratePortDependency $library)
    }
    finally {
        Pop-Location
    }
}

if ($updateServicePorts) {
    # Generate manifest file for master boost port which depends on each individual library
    GeneratePortManifest `
        -PortName "boost" `
        -Homepage "https://boost.org" `
        -Description "Peer-reviewed portable C++ source libraries" `
        -License "BSL-1.0" `
        -Dependencies $boostPortDependencies

    Set-Content -LiteralPath "$portsDir/boost/portfile.cmake" `
        -Value "set(VCPKG_POLICY_EMPTY_PACKAGE enabled)`n" `
        -Encoding UTF8 `
        -NoNewline

    # Generate manifest files for boost-uninstall
    GeneratePortManifest `
        -PortName "boost-uninstall" `
        -Description "Internal vcpkg port used to uninstall Boost" `
        -License "MIT"

    # Generate manifest files for boost-vcpkg-helpers
    GeneratePortManifest `
        -PortName "boost-vcpkg-helpers" `
        -Description "Internal vcpkg port used to modularize Boost" `
        -License "MIT" `
        -Dependencies @("boost-uninstall")

    # Generate manifest files for boost-modular-build-helper
    GeneratePortManifest `
        -PortName "boost-modular-build-helper" `
        -Description "Internal vcpkg port used to build Boost libraries" `
        -License "MIT" `
        -Dependencies @("boost-uninstall", "vcpkg-cmake")

    # Generate manifest files for boost-build
    GeneratePortManifest `
        -PortName "boost-build" `
        -Homepage "https://github.com/boostorg/build" `
        -Description "Boost.Build" `
        -License "BSL-1.0" `
        -Dependencies @("boost-uninstall")

    # Update Boost version in CMake files
    $files_with_boost_version = @(
        "$portsDir/boost-build/portfile.cmake",
        "$portsDir/boost-modular-build-helper/boost-modular-build.cmake",
        "$portsDir/boost-vcpkg-helpers/portfile.cmake"
    )
    $files_with_boost_version | % {
        $content = Get-Content -LiteralPath $_ `
            -Encoding UTF8 `
            -Raw
        $content = $content -replace `
            "set\(BOOST_VERSION [0-9\.]+\)", `
            "set(BOOST_VERSION $version)"

        Set-Content -LiteralPath $_ `
            -Value $content `
            -Encoding UTF8 `
            -NoNewline
    }
}
