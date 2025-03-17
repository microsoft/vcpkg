[CmdletBinding()]
param (
    $libraries = @(),
    $version = "1.87.0",
# 1: boost-cmake/ref_sha.cmake needs manual updating
# 2: This script treats support statements as platform expressions. This is incorrect
#    in a few cases e.g. boost-parameter-python not depending on boost-python for uwp since
#    boost-python is not supported on uwp. Update $suppressPlatformForDependency as needed,
#    don't blindly stage/commit changes containing platform expressions in dependencies.
    $portsDir = $null,
    $vcpkg = $null
)

$ErrorActionPreference = 'Stop'

$scriptsBoostDir = split-path -parent $MyInvocation.MyCommand.Definition
if ($null -eq $portsDir) {
    $portsDir = "$scriptsBoostDir/../../ports"
}
if ($null -eq $vcpkg) {
    $vcpkg = "$scriptsBoostDir/../../vcpkg"
}


# Beta builds contains a text in the version string
$semverVersion = ($version -replace "(\d+(\.\d+){1,3}).*", "`$1")

# Clear this array when moving to a new boost version
$defaultPortVersion = 0
$portVersions = @{
    'boost' = 1;
    'boost-asio' = 1;
    'boost-atomic' = 1;
    'boost-cobalt' = 1;
    'boost-compute' = 1;
    'boost-context' = 1;
    'boost-flyweight' = 1;
    'boost-interprocess' = 1;
    'boost-json' = 1;
    'boost-lexical-cast' = 1;
    'boost-lockfree' = 1;
    'boost-mysql' = 1;
    'boost-optional' = 1;
    'boost-parser' = 1;
    'boost-process' = 1;
    'boost-regex' = 1;
    'boost-unordered' = 1;
}

function Get-PortVersion {
    param (
        [string]$PortName
    )

    $nonDefault = $portVersions[$PortName]
    if ($null -ne $nonDefault) {
        return $nonDefault
    }

    return $defaultPortVersion
}

$portData = @{
    "boost"                  = @{
        "features" = @{
            "mpi" = @{
                "description"  = "Build with MPI support";
                "dependencies" = @("boost-mpi", "boost-graph-parallel", "boost-property-map-parallel");
            };
            "cobalt" = @{
                "description"  = "Build boost-cobalt";
                "dependencies" = @(@{ "name" = "boost-cobalt"; "platform" = "!osx & !ios & !android & !uwp" });
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
    "boost-cobalt"           = @{ "supports" = "!uwp" };
    "boost-context"          = @{ "supports" = "!uwp & !emscripten" };
    "boost-coroutine"        = @{ "supports" = "!(arm & windows) & !uwp & !emscripten" };
    "boost-fiber"            = @{
        "supports" = "!uwp & !(arm & windows) & !emscripten";
        "features" = @{
            "numa" = @{
                "description" = "Enable NUMA support";
            }
        }
    };
    "boost-filesystem"       = @{ "supports" = "!uwp" };
    "boost-function"         = @{ "dependencies" = @("boost-type-traits"); };
    "boost-geometry"         = @{ "dependencies" = @("boost-crc", "boost-program-options"); };
    "boost-graph-parallel"   = @{ "dependencies" = @("mpi"); };
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
    "boost-log"              = @{ "supports" = "!uwp & !emscripten" };
    "boost-math"             = @{
        "features" = @{
            "legacy" = @{
                "description"  = "Build the legacy C99 and TR1 libraries";
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
                "dependencies" = @(@{ "name" = "boost-python"; "platform" = "!uwp & !emscripten & !ios & !android" }, "python3");
            }
        }
    };
    "boost-mysql"            = @{ "dependencies" = @("openssl"); };
    "boost-odeint"           = @{
        "features" = @{
            "mpi" = @{
                "description"  = "Support parallelization with MPI";
                "dependencies" = @("boost-mpi");
            }
        }
    };
    "boost-process"          = @{ "supports" = "!uwp & !emscripten & !android" };
    "boost-python"           = @{ "supports" = "!uwp & !emscripten & !ios & !android"; "dependencies" = @("python3");};
    "boost-random"           = @{ "supports" = "!uwp" };
    "boost-regex"            = @{
        "features" = @{
            "icu" = @{
                "description"  = "ICU backend for Boost.Regex";
                "dependencies" = @("icu");
            }
        }
    }
    "boost-stacktrace"       = @{
        "default-features" = @(@{ "name" = "backtrace"; "platform" = "!windows" }; @{ "name" = "windbg"; "platform" = "windows" });
        "supports"         = "!uwp";
        "features"         = @{
            "backtrace" = @{
                "description"  = "Use boost_stacktrace_backtrace";
                "supports"     = "!windows";
                "dependencies" = @(@{ "name" = "libbacktrace"; "platform" = "!windows" });
            };
            "windbg" = @{
                "description"  = "Use boost_stacktrace_windbg";
                "supports"     = "windows";
            };
        }
    };
    "boost-test"             = @{ "supports" = "!uwp" };
    "boost-wave"             = @{ "supports" = "!uwp" };
}

# For some dependent ports (LHS), the dependency's [RHS] "supports" is enough,
# and no "platform" field shall be added to the dependency.
$suppressPlatformForDependency = @{
    "boost-coroutine2"            = @("boost-context");
    "boost-dll"                   = @("boost-filesystem");
    "boost-graph"                 = @("boost-random");
    "boost-parameter-python"      = @("boost-python");
    "boost-property-map-parallel" = @("boost-mpi");
}

function GeneratePortName() {
    param (
        [string]$Library
    )
    "boost-" + ($Library -replace "_", "-")
}

function GetPortHomepage() {
    param (
        [string]$Library
    )

    $specicalHomepagePaths = @{
        "interval"           = "numeric/interval";
        "numeric_conversion" = "numeric/conversion";
        "odeint"             = "numeric/odeint";
        "ublas"              = "numeric/ublas";
    }

    if ($specicalHomepagePaths.ContainsKey($Library)) {
        $homepagePath = $specicalHomepagePaths[$Library]
    } else {
        $homepagePath = $Library
    }

    "https://www.boost.org/libs/" + $homepagePath
}

function GeneratePortDependency() {
    param (
        [string]$Library = '',
        [string]$PortName = '',
        [string]$ForLibrary = ''
    )
    if ($PortName -eq '') {
        $PortName = GeneratePortName $Library
    }
    $forPortName = GeneratePortName $ForLibrary
    if ($suppressPlatformForDependency.Contains($forPortName) -and $suppressPlatformForDependency[$forPortName].Contains($PortName)) {
        $PortName
    }
    elseif ($portData.Contains($PortName) -and $portData[$PortName].Contains('supports')) {
        @{name = $PortName; platform = $portData[$PortName]['supports'] }
    }
    elseif ($ForLibrary -eq '' -and $suppressPlatformForDependency.Contains($PortName)) {
        # For 'boost'.
        $platform = `
            $suppressPlatformForDependency[$PortName] `
        | ForEach-Object { (GeneratePortDependency -PortName $_).platform } `
        | Group-Object -NoElement `
        | Join-String -Property Name -Separator ' & '
        if ($platform -ne '') {
            @{name = $PortName; platform = $platform }
        }
        else {
            $PortName
        }
    }
    else {
        $PortName
    }
}

function AddBoostVersionConstraints() {
    param (
        $Dependencies = @()
    )

    $updatedDependencies = @()
    foreach ($dependency in $Dependencies) {
        if ($dependency.Contains("name")) {
            if ($dependency.name.StartsWith("boost")) {
                $dependency["version>="] = $semverVersion
            }
        }
        else {
            if ($dependency.StartsWith("boost")) {
                $dependency = @{
                    "name"       = $dependency
                    "version>="  = $semverVersion
                }
            }
        }
        $updatedDependencies += $dependency
    }
    $updatedDependencies
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
        "`$comment"       = "Automatically generated by scripts/boost/generate-ports.ps1"
        "name"            = $PortName
        "homepage"        = $Homepage
        "description"     = $Description
    }
    if ($version -eq $semverVersion) {
        $manifest["version"] = $version
    }
    else {
        $manifest["version-string"] = $version
    }
    if ($License) {
        $manifest["license"] += $License
    }
    if ($portData.Contains($PortName)) {
        $manifest += $portData[$PortName]
    }
    $thisPortVersion = Get-PortVersion $PortName
    if ($thisPortVersion -ne 0) {
        $manifest["port-version"] = $thisPortVersion
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
                    }
                    else {
                        $_ -notmatch "$dep_name"
                    }
                }
            }
        }
    }

    # Add version constraints to boost dependencies
    $manifest["dependencies"] = @(AddBoostVersionConstraints $manifest["dependencies"])
    foreach ($feature in $manifest.features.Keys) {
        $manifest.features.$feature["dependencies"] = @(AddBoostVersionConstraints $manifest.features.$feature["dependencies"])
    }

    $manifest | ConvertTo-Json -Depth 10 -Compress `
    | Out-File -Encoding UTF8 "$portsDir/$PortName/vcpkg.json"
    & $vcpkg format-manifest "$portsDir/$PortName/vcpkg.json"
}

function GeneratePort() {
    param (
        [string]$Library,
        [string]$Hash,
        $Dependencies = @()
    )

    $portName = GeneratePortName $Library
    $homepage = GetPortHomepage  $Library

    New-Item -ItemType "Directory" "$portsDir/$portName" -erroraction SilentlyContinue | out-null

    # Generate vcpkg.json
    GeneratePortManifest `
        -PortName $portName `
        -Homepage $homepage `
        -Description "Boost $Library module" `
        -License "BSL-1.0" `
        -Dependencies $Dependencies

    $portfileLines = @(
        "# Automatically generated by scripts/boost/generate-ports.ps1"
        ""
    )

    if (Test-Path "$scriptsBoostDir/pre-source-stubs/$Library.cmake") {
        $portfileLines += @(Get-Content "$scriptsBoostDir/pre-source-stubs/$Library.cmake")
    }

    $portfileLines += @(
        "vcpkg_from_github(",
        "    OUT_SOURCE_PATH SOURCE_PATH",
        "    REPO boostorg/$Library",
        "    REF boost-`${VERSION}",
        "    SHA512 $Hash",
        "    HEAD_REF master"
    )

    [string[]]$allmods = @()
    $allmods += Get-ChildItem -Path "$portsDir/$portName/*" -Name -Include @('*.patch', '*.diff')
    if (Test-Path "$scriptsBoostDir/patch-stubs/$Library.txt") {
        $allmods +=  Get-Content "$scriptsBoostDir/patch-stubs/$Library.txt"
    }

    if ($allmods.Length -ne 0) {
        $portfileLines += @("    PATCHES")
        foreach ($patch in $allmods) {
            $portfileLines += "        $patch"
        }
    }
    $portfileLines += @(
        ")"
        ""
    )

    if (Test-Path "$scriptsBoostDir/post-source-stubs/$Library.cmake") {
        $portfileLines += @(Get-Content "$scriptsBoostDir/post-source-stubs/$Library.cmake")
    }

    $portfileLines += @(
        "set(FEATURE_OPTIONS `"`")"
    )
    if (Test-Path "$portsDir/$portName/features.cmake") {
        $portfileLines += @(
            "include(`"`${CMAKE_CURRENT_LIST_DIR}/features.cmake`")"
        )
    }

    if (Test-Path "$scriptsBoostDir/pre-build-stubs/$Library.cmake") {
        $portfileLines += Get-Content "$scriptsBoostDir/pre-build-stubs/$Library.cmake"
    }

    $portfileLines += @(
        "boost_configure_and_install("
        "    SOURCE_PATH `"`${SOURCE_PATH}`""
        "    OPTIONS `${FEATURE_OPTIONS}"
        ")"
    )

    if (Test-Path "$scriptsBoostDir/post-build-stubs/$Library.cmake") {
        $portfileLines += @(Get-Content "$scriptsBoostDir/post-build-stubs/$Library.cmake")
    }

    $portfileLines += @("")
    Set-Content -LiteralPath "$portsDir/$portName/portfile.cmake" `
        -Value "$($portfileLines -join "`n")" `
        -Encoding UTF8 `
        -NoNewline
}

if (!(Test-Path "$scriptsBoostDir/boost")) {
    "Cloning boost..."
    Push-Location $scriptsBoostDir
    try {
        git clone https://github.com/boostorg/boost --branch boost-$version
    }
    finally {
        Pop-Location
    }
}
else {
    Push-Location $scriptsBoostDir/boost
    try {
        git fetch
        git checkout -f boost-$version
    }
    finally {
        Pop-Location
    }
}

$foundLibraries = Get-ChildItem $scriptsBoostDir/boost/libs -directory | ForEach-Object name | ForEach-Object {
    if ($_ -eq "numeric") {
        "numeric_conversion"
        "interval"
        "odeint"
        "ublas"
    }
    else {
        $_
    }
}

$downloads = "$scriptsBoostDir/../../downloads"
New-Item -ItemType "Directory" $downloads -erroraction SilentlyContinue | out-null

$updateServicePorts = $false

if ($libraries.Length -eq 0) {
    $libraries = $foundLibraries
    $updateServicePorts = $true
}

$boostPortDependencies = @()

foreach ($library in $libraries) {
    $archive = "$downloads/boostorg-$library-boost-$version.tar.gz"
    "Handling boost/$library... $archive"
    if (!(Test-Path $archive)) {
        "Downloading boost/$library..."
        Invoke-WebRequest -Uri "https://github.com/boostorg/$library/archive/boost-$version.tar.gz" -OutFile "$archive"
        "Downloaded boost/$library..."
    }
    $hash = & $vcpkg --x-wait-for-lock hash $archive
    # Remove prefix "Waiting to take filesystem lock on <path>/.vcpkg-root... "
    if ($hash -is [Object[]]) {
        $hash = $hash[1]
    }

    $unpacked = "$scriptsBoostDir/libs/$library-boost-$version"
    if (!(Test-Path $unpacked)) {
        "Unpacking boost/$library..."
        New-Item -ItemType "Directory" $scriptsBoostDir/libs -erroraction SilentlyContinue | out-null
        Push-Location $scriptsBoostDir/libs
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
            Get-Content -LiteralPath $_.FullName
        } `
        | Where-Object {
            $_ -match ' *# *include *[<"]boost\/'
        } `
        | ForEach-Object {
            # Extract path from the line
            Write-Verbose "${library}: processing line: $_"
            $_ -replace " *# *include *[<`"]boost\/([a-zA-Z0-9\.\-_\/]*)[>`"].*", "`$1"
        }`
        | ForEach-Object {
            # Map the path to the library name
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
            # Extract first directory name or file name from the path
            else { $_ -replace "([a-zA-Z0-9\.\-_]*).*", "`$1" }
        } `
        | ForEach-Object {
            # Map directory/file name to the library name
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
            # By dafault use the name as is, just remove the file extension if available
            else { $_ -replace "\.hp?p?", "" }
        } `
        | Where-Object {
            $_ -ne $library
        } `
        | Group-Object -NoElement | ForEach-Object Name

        "  [known] " + $($usedLibraries | Where-Object { $foundLibraries -contains $_ })
        "[unknown] " + $($usedLibraries | Where-Object { $foundLibraries -notcontains $_ })

        $deps = @($usedLibraries | Where-Object { $foundLibraries -contains $_ })

        # Remove optional dependencies that are only used for tests or examples
        $deps = @($deps | Where-Object {
                -not (
                ($library -eq 'gil' -and $_ -eq 'filesystem') # PR #20575
                )
            }
        )
        $deps = @($deps | Where-Object {
                -not (
                ($library -eq 'mysql' -and $_ -eq 'pfr')
                )
            }
        )

        # Add dependency to the config for all libraries except the config library itself
        if ($library -ne 'config' -and $library -ne 'headers') {
            # Note: CMake's built-in finder (FindBoost.cmake) looks for Boost header files (boost/version.h or boost/config.h)
            # and stores the result in the Boost_INCLUDE_DIR variable. The files boost/version.h or boost/config.h are owned by the config library.
            # Without these files, the Boost_INCLUDE_DIR variable will not be set and the Boost version will not be detected.
            $deps += @('config')
            $deps = $deps | Select-Object -Unique
        }

        $deps = @($deps | ForEach-Object { GeneratePortDependency $_ -ForLibrary $library })

        if ($library -ne 'cmake') {
            $deps += @("boost-cmake")
            if ($library -ne 'headers') {
                $deps += @("boost-headers")
            }
        }

        GeneratePort `
            -Library $library `
            -Hash $hash `
            -Dependencies $deps

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
        -PortName "boost-cmake" `
        -Homepage "https://github.com/boostorg/cmake" `
        -Description "Boost CMake support infrastructure" `
        -License "BSL-1.0" `
        -Dependencies @("boost-uninstall", @{ name = "vcpkg-boost"; host = $true }, @{ name = "vcpkg-cmake"; host = $true }, @{ name = "vcpkg-cmake-config"; host = $true })


    # Generate manifest files for boost-build
    GeneratePortManifest `
        -PortName "boost-build" `
        -Homepage "https://github.com/boostorg/build" `
        -Description "Boost.Build" `
        -License "BSL-1.0" `
        -Dependencies @("boost-uninstall")

}
