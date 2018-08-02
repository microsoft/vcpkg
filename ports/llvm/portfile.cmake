include(CMakeParseArguments)
include(vcpkg_common_functions)

# LLVM documentation recommends always using static library linkage when
#   building with Microsoft toolchain; it's also the default on other platforms
set(VCPKG_LIBRARY_LINKAGE static)
set(LLVM_VERSION "6.0.1")

# TODO: 
# what about LLVM_BUILD_STATIC? --- make it on base of the triplet name
# Not supported on windows, but can be used on linux/mac
# LTO must be also static when triplet is static
# list(APPEND _COMPONENT_FLAGS "-DLLVM_BUILD_STATIC=ON")
# list(APPEND _COMPONENT_FLAGS "-DLIBOMP_ENABLE_SHARED=OFF")

# CLANG_ANALYZER_BUILD_Z3
# CLANG_ENABLE_PROTO_FUZZER

# Clang maybe use stage2?
# https://github.com/llvm-mirror/clang/tree/master/cmake/caches
# CLANG_ENABLE_BOOTSTRAP

# Doxygen requires Graphviz (dot) - Add to PATH
# https://ci.appveyor.com/api/buildjobs/w96x513p36twogfm/artifacts/graphviz-windows.zip
# Make Graphviz multiplatform

# Selecting targets does not work, whatever I make its passes as "-DLLVM_TARGETS_TO_BUILD="Mips" "X86""
# and not as -DLLVM_TARGETS_TO_BUILD="Mips;X86".
# It's a CMake bug or VCPKG?

if("${VCPKG_CMAKE_SYSTEM_NAME}" STREQUAL "WindowsStore")
    message(FATAL_ERROR "llvm cannot currently be built for UWP")
endif()

function(llvm_download)
    cmake_parse_arguments(PARSE_ARGV 0 VCPKG_LLVM_DL "" "NAME;SHA512;PKG_NAME;EXTRACT_TO;FOLDER_NAME" "")
    if ("${VCPKG_LLVM_DL_PKG_NAME}" STREQUAL "")
        set(VCPKG_LLVM_DL_PKG_NAME "${VCPKG_LLVM_DL_NAME}")
    endif()
    if ("${VCPKG_LLVM_DL_EXTRACT_TO}" STREQUAL "")
        set(VCPKG_LLVM_DL_EXTRACT_TO "tools")
    endif()
    if ("${VCPKG_LLVM_DL_FOLDER_NAME}" STREQUAL "")
        set(VCPKG_LLVM_DL_FOLDER_NAME "${VCPKG_LLVM_DL_NAME}")
    endif()

    string(TOUPPER "${VCPKG_LLVM_DL_NAME}" _pkgName)

    vcpkg_download_distfile(${_pkgName}_ARCHIVE
        URLS "http://releases.llvm.org/${LLVM_VERSION}/${VCPKG_LLVM_DL_PKG_NAME}-${LLVM_VERSION}.src.tar.xz"
        FILENAME "${VCPKG_LLVM_DL_PKG_NAME}-${LLVM_VERSION}.src.tar.xz"
        SHA512 ${VCPKG_LLVM_DL_SHA512}
    )
    vcpkg_extract_source_archive("${${_pkgName}_ARCHIVE}" ${SOURCE_PATH}/${VCPKG_LLVM_DL_EXTRACT_TO})

    set(VCPKG_LLVM_DL_FOLDER_BASE "${SOURCE_PATH}/${VCPKG_LLVM_DL_EXTRACT_TO}")
    set(VCPKG_LLVM_DL_FOLDER_TEST "${VCPKG_LLVM_DL_FOLDER_BASE}/${VCPKG_LLVM_DL_FOLDER_NAME}")
    if(NOT EXISTS ${VCPKG_LLVM_DL_FOLDER_TEST})
        file(RENAME ${VCPKG_LLVM_DL_FOLDER_BASE}/${VCPKG_LLVM_DL_PKG_NAME}-${LLVM_VERSION}.src ${VCPKG_LLVM_DL_FOLDER_TEST})
    endif()  
endfunction(llvm_download)

function(llvm_assert_array)
    cmake_parse_arguments(PARSE_ARGV 0 VCPKG_LLVM_AA "" "WHERE;MATCH;NAME" "")
    foreach(_component IN LISTS VCPKG_LLVM_AA_WHERE)
        if ("${_component}" MATCHES "^${VCPKG_LLVM_AA_MATCH}")
            message(FATAL_ERROR "The ${VCPKG_LLVM_AA_NAME} is already set.")
        endif()
    endforeach()
endfunction(llvm_assert_array)

# Install must-have software
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PYTHON3_DIR}")

# Download and extract the main LLVM project
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/llvm-${LLVM_VERSION}.src)
vcpkg_download_distfile(ARCHIVE
    URLS "http://releases.llvm.org/${LLVM_VERSION}/llvm-${LLVM_VERSION}.src.tar.xz"
    FILENAME "llvm-${LLVM_VERSION}.src.tar.xz"
    SHA512 cbbb00eb99cfeb4aff623ee1a5ba075e7b5a76fc00c5f9f539ff28c108598f5708a0369d5bd92683def5a20c2fe60cab7827b42d628dbfcc79b57e0e91b84dd9
)
vcpkg_extract_source_archive(${ARCHIVE})

# From: https://github.com/llvm-mirror/llvm/blob/master/CMakeLists.txt
set(_LLVM_ALL_TARGETS
    AArch64
    AMDGPU
    ARM
    BPF
    Hexagon
    Lanai
    Mips
    MSP430
    NVPTX
    PowerPC
    Sparc
    SystemZ
    X86
    XCore
)

set(_COMPONENT_FLAGS "")
set(_COMPONENT_PATCHES "")
set(_COMPONENT_TARGETS "")

foreach(_feature IN LISTS FEATURES)
    if ("${_feature}" MATCHES "^enable-")
        # Uppercase the feature name and replace "-" with "_"
        string(TOUPPER "${_feature}" _FEATURE)
        string(REPLACE "-" "_" _FEATURE "${_FEATURE}")

        list(APPEND _COMPONENT_FLAGS "-DLLVM_${_FEATURE}=ON")
    elseif ("${_feature}" MATCHES "^abi-breaking-checks-")
        string(REPLACE "abi-breaking-checks-" "" _featureValue "${_feature}")
        llvm_assert_array(
            NAME "abi-breaking-checks"
            WHERE ${_COMPONENT_FLAGS}
            MATCH "-DLLVM_ABI_BREAKING_CHECKS="
        )
        if ("${_featureValue}" STREQUAL "on")
            list(APPEND _COMPONENT_FLAGS "-DLLVM_ABI_BREAKING_CHECKS=FORCE_ON")
        elseif ("${_featureValue}" STREQUAL "off")
            list(APPEND _COMPONENT_FLAGS "-DLLVM_ABI_BREAKING_CHECKS=FORCE_OFF")
        endif()
    elseif ("${_feature}" STREQUAL "single")
        if ("${VCPKG_CMAKE_SYSTEM_NAME}" STREQUAL "")
            message(FATAL_ERROR "The libLVVM (single shared library) does not work on Windows yet.")
        else()
            list(APPEND _COMPONENT_FLAGS "-DLLVM_LINK_LLVM_DYLIB=ON")
        endif()
    elseif ("${_feature}" STREQUAL "clang")
        llvm_download(
            NAME clang
            PKG_NAME cfe
            SHA512 f64ba9290059f6e36fee41c8f32bf483609d31c291fcd2f77d41fecfdf3c8233a5e23b93a1c73fed03683823bd6e72757ed993dd32527de3d5f2b7a64bb031b9
        )
        list(APPEND _COMPONENT_FLAGS "-DLIBCLANG_BUILD_STATIC=ON")
    elseif ("${_feature}" STREQUAL "clang-protobuf-fuzzer")
        list(APPEND _COMPONENT_FLAGS "-DCLANG_ENABLE_PROTO_FUZZER=ON")
    elseif ("${_feature}" STREQUAL "clang-tools-extra")
        llvm_download(
            NAME clang-tools-extra
            SHA512 cf29d117b6dabcb7a8e5f6dab5016ce5a5c8f475679001a43fd5c935f2c368f37cdef50aae2080a1e4524f647f6d83458d4a5dec5b45d03fb374f463caf7c3f5
            EXTRACT_TO tools/clang/tools
            FOLDER_NAME extra
        )
        list(APPEND _COMPONENT_FLAGS "-DCLANG_ENABLE_STATIC_ANALYZER=ON")
    elseif ("${_feature}" STREQUAL "clang-enable-z3-analyzer")
        list(APPEND _COMPONENT_FLAGS "-DCLANG_ANALYZER_BUILD_Z3=ON")
    elseif ("${_feature}" STREQUAL "lldb")
        llvm_download(
            NAME lldb
            SHA512 93ee2efea07276f8838bc2b3ff039cab8c7a1a6965647aaa4dee99f55c6465d5584ed3be87b144e2e32b5acc7db9cec56d89404de764a2f53643ed154d213721
        )
        # Based on https://github.com/llvm-mirror/lldb/commit/b16e8c12330ba21fb45b7d8b1e6ee3f8510b2846
        # Only applies for LLDB 6.x version
        list(APPEND _COMPONENT_PATCHES "${CMAKE_CURRENT_LIST_DIR}/lldb-mi-signal-msvc.patch")

        if (NOT "lldb-python3" IN_LIST FEATURES OR NOT "lldb-python2" IN_LIST FEATURES)
            list(APPEND _COMPONENT_FLAGS "-DLLDB_DISABLE_PYTHON=ON")
        endif()
    elseif ("${_feature}" MATCHES "^lldb-python")
        if ("-DLLDB_BUILD_FRAMEWORK=ON" IN_LIST _COMPONENT_FLAGS)
            message(FATAL_ERROR "You can not compile lldb with support for python2 and python3. Please select only one version.")
        endif()

        vcpkg_find_acquire_program(SWIG)
        get_filename_component(SWIG_DIR "${SWIG}" DIRECTORY)
        set(ENV{PATH} "$ENV{PATH};${SWIG_DIR}")

        # Requires python and swig
        string(REPLACE "lldb-python" "" _featureValue "${_feature}")
        find_package (Python${_featureValue} COMPONENTS Development)
        list(APPEND _COMPONENT_FLAGS "-DPYTHON_HOME=${Python${_featureValue}_ROOT_DIR}")
        list(APPEND _COMPONENT_FLAGS "-DLLDB_BUILD_FRAMEWORK=ON")
    elseif ("${_feature}" STREQUAL "lld")
        llvm_download(
            NAME lld
            SHA512 856ccc125255ab6184919f1424372f0f8a5de8477777047e2ab1a131a2ecec0caa9b5163d01409c7c510df9c794f0bc8d65cc904df2baf6462ef53bc163e002a
        )
    elseif ("${_feature}" STREQUAL "polly")
        llvm_download(
            NAME polly
            SHA512 1851223653f8c326ddf39f5cf9fc18a2310299769c011795d8e1a5abef2834d2c800fae318e6370547d3b6b35199ce29fe76582b64493ab8fa506aff59272539
        )
    elseif ("${_feature}" STREQUAL "polly-gpu")
        if ("${VCPKG_CMAKE_SYSTEM_NAME}" STREQUAL "")
            message(FATAL_ERROR "The polly-gpu does not work on Windows yet.")
        else()
            list(APPEND _COMPONENT_FLAGS "-DPOLLY_ENABLE_GPGPU_CODEGEN=ON")
        endif()
    elseif ("${_feature}" STREQUAL "compiler-rt")
        llvm_download(
            NAME compiler-rt
            EXTRACT_TO projects
            SHA512 69850c1ad92c66977fa217cbfb42a6a3f502fbe3d1a08daa7fc4cfeb617a7736d231f8ad8d93b10b1ae29bd753315d2a2d70f9ff1f4d18a9a7cc81758d91f963
        )
    elseif ("${_feature}" STREQUAL "libunwind")
        if ("${VCPKG_CMAKE_SYSTEM_NAME}" STREQUAL "")
            message(FATAL_ERROR "The libunwind does not work on Windows yet.")
        else()
            llvm_download(
                NAME libunwind
                SHA512 78568c28720abdd1f8471c462421df9965e05e1db048689d16ac85378716c4080ec1723af78e9f61d133b0ff82ac8c1f0dde7fd42d194485f62c1a17c02db37f
            )
            list(APPEND _COMPONENT_FLAGS "-DLIBUNWIND_ENABLE_CROSS_UNWINDING=ON")
            list(APPEND _COMPONENT_FLAGS "-DLIBUNWIND_ENABLE_ARM_WMMX=ON")
            if ("compiler-rt" IN_LIST FEATURES)
                list(APPEND _COMPONENT_FLAGS "-DLIBUNWIND_USE_COMPILER_RT=ON")
            endif()
            list(APPEND _COMPONENT_FLAGS "-DLIBUNWIND_ENABLE_STATIC=ON")
            list(APPEND _COMPONENT_FLAGS "-DLIBUNWIND_ENABLE_SHARED=OFF")
        endif()
    elseif ("${_feature}" STREQUAL "libomp")
        llvm_download(
            NAME openmp
            EXTRACT_TO projects
            SHA512 abb956583e5d11d0c6f6d97183c081d658616a74933be884a591eaa3d8c4bb04f08f02016d2c86d7384c7ff1aa44fb949b0d967fc0ff50e3132aaba412e9add8
        )
        vcpkg_find_acquire_program(PERL)
        get_filename_component(PERL_PATH ${PERL} DIRECTORY)
        set(ENV{PATH} "$ENV{PATH};${PERL_PATH}")

        # If libomp-ompt-off is defined, that will be ignored
        list(APPEND _COMPONENT_FLAGS "-DLIBOMP_OMPT_OPTIONAL=ON")

        # On Windows libomp does not support static linkage
        if ("${VCPKG_CMAKE_SYSTEM_NAME}" STREQUAL "")
            message(STATUS "Warning: On Windows platform libomp does not support static linkage. ")
        else()
            list(APPEND _COMPONENT_FLAGS "-DLIBOMP_ENABLE_SHARED=OFF")
        endif()

    elseif ("${_feature}" MATCHES "^libomp-")
        string(REPLACE "libomp-" "" _featureValue "${_feature}")

        if ("${_featureValue}" STREQUAL "debugger")
            if ("${VCPKG_CMAKE_SYSTEM_NAME}" STREQUAL "")
                message(FATAL_ERROR "The libomp-debugger does not work on Windows yet.")
            else()
                list(APPEND _COMPONENT_FLAGS "-DLIBOMP_USE_DEBUGGER=ON")
            endif()
        elseif ("${_featureValue}" STREQUAL "stats")
            if ("${VCPKG_CMAKE_SYSTEM_NAME}" STREQUAL "")
                message(FATAL_ERROR "The stats-gathering code does not work on Windows yet.")
            else()
                list(APPEND _COMPONENT_FLAGS "-DLIBOMP_STATS=ON")
            endif()
        elseif ("${_featureValue}" STREQUAL "ompt-off")
            list(APPEND _COMPONENT_FLAGS "-DLIBOMP_OMPT_SUPPORT=OFF")
        endif()
    elseif ("${_feature}" STREQUAL "doxygen")
        vcpkg_find_acquire_program(DOXYGEN)
        get_filename_component(DOXYGEN_PATH ${DOXYGEN} DIRECTORY)
        set(ENV{PATH} "$ENV{PATH};${DOXYGEN_PATH}")

        set(_GRAPHVIZ_PATH ${CURRENT_BUILDTREES_DIR}/graphviz)
        vcpkg_download_distfile(GRAPHVIZ_ARCHIVE
            URLS "https://ci.appveyor.com/api/buildjobs/w96x513p36twogfm/artifacts/graphviz-windows.zip"
            FILENAME "graphviz-windows.zip"
            SHA512 b5b17e2986772237556ba93b91bd9dab49c60d41c169a9b3cd7faa14db5a7fcb0d6fe3ddc087e5e2424b62bc01ca5c8b686f11c9a7f52b449fb7a5d69ce2a0c1
        )
        vcpkg_extract_source_archive(${GRAPHVIZ_ARCHIVE} ${_GRAPHVIZ_PATH})
        set(ENV{PATH} "$ENV{PATH};${_GRAPHVIZ_PATH}/Graphviz/bin")

        list(APPEND _COMPONENT_FLAGS "-DLLVM_BUILD_DOCS=ON")
        list(APPEND _COMPONENT_FLAGS "-DLLVM_ENABLE_DOXYGEN=ON")
        list(APPEND _COMPONENT_FLAGS "-DLLVM_DOXYGEN_SVG=ON")
    #elseif ("${_feature}" STREQUAL "libcxx")
    # TODO must be compiled with CLANG when using ninja
    #    llvm_download(
    #        NAME libcxx
    #        EXTRACT_TO projects
    #        SHA512 c04f628b0924d76f035f615b59d19ce42dfc19c9a8eea4fe2b22a95cfe5a037ebdb30943fd741443939df5b4cf692bc1e51c840fefefbd134e3afbe2a75fe875
    #    )
    #    llvm_download(
    #        NAME libcxxabi
    #        EXTRACT_TO projects
    #        SHA512 bbb4c7b412e295cb735f637df48a83093eef45ed5444f7766790b4b047f75fd5fd634d8f3a8ac33a5c1407bd16fd450ba113f60a9bcc1d0a911fe0c54e9c81f2
    #    )
    elseif ("${_feature}" MATCHES "^target-")
        string(REPLACE "target-" "" _featureValue "${_feature}")
        foreach(_TARGETNAME IN LISTS _LLVM_ALL_TARGETS)
            string(TOLOWER "${_TARGETNAME}" _targetName)
            message(STATUS "${_targetName}-${_TARGETNAME}")
            if ("${_featureValue}" STREQUAL "${_targetName}")
                list(APPEND _COMPONENT_TARGETS "${_TARGETNAME}")
                break()
            endif()
        endforeach()
    elseif ("${_feature}" MATCHES "^use-sanitizer-")
        llvm_assert_array(
            NAME "sanitizer"
            WHERE ${_COMPONENT_FLAGS}
            MATCH "-DLLVM_USE_SANITIZER="
        )

        string(REPLACE "use-sanitizer-" "" _featureValue "${_feature}")
        if ("${_featureValue}" STREQUAL "addr")
            list(APPEND _COMPONENT_FLAGS "-DLLVM_USE_SANITIZER=Address")
        elseif ("${_featureValue}" STREQUAL "mem")
            list(APPEND _COMPONENT_FLAGS "-DLLVM_USE_SANITIZER=Memory")
        elseif ("${_featureValue}" STREQUAL "mem-origins")
            list(APPEND _COMPONENT_FLAGS "-DLLVM_USE_SANITIZER=MemoryWithOrigins")
        elseif ("${_featureValue}" STREQUAL "undef")
            list(APPEND _COMPONENT_FLAGS "-DLLVM_USE_SANITIZER=Undefined")
        elseif ("${_featureValue}" STREQUAL "thread")
            list(APPEND _COMPONENT_FLAGS "-DLLVM_USE_SANITIZER=Thread")
        elseif ("${_featureValue}" STREQUAL "addr-undef")
            # list(APPEND _COMPONENT_FLAGS "-DLLVM_USE_SANITIZER=Address\;Undefined")
            message(FATAL_ERROR "The feature use-sanitizer-addr-undef is not supported yet.")
        endif()

        list(APPEND _COMPONENT_FLAGS "-DLLVM_USE_SANITIZE_COVERAGE=ON")

        if ("compiler-rt" IN_LIST FEATURES)
            message(STATUS "Warning: Avoiding building the sanitizers themselves with sanitizers enabled because of \"compiler-rt\" is enabled.")
            list(APPEND _COMPONENT_FLAGS "-DLLVM_BUILD_RUNTIME=OFF")
        endif()
    endif()
endforeach()

# If the "all" target is defined in FEATURES, replace _COMPONENT_TARGETS
if ("all" IN_LIST _COMPONENT_TARGETS OR "target-all" IN_LIST FEATURES)
    set(_COMPONENT_TARGETS "all")
endif()

# Based on https://github.com/numba/llvmlite/blob/master/conda-recipes/llvm-lto-static.patch
list(APPEND _COMPONENT_PATCHES "${CMAKE_CURRENT_LIST_DIR}/llvm-lto-static.patch")
list(APPEND _COMPONENT_FLAGS "-DLLVM_BUILD_STATIC=ON")

# Appyl patches
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/install-cmake-modules-to-share.patch
        ${CMAKE_CURRENT_LIST_DIR}/force-bigobj-modules-llvm-options.patch
        ${CMAKE_CURRENT_LIST_DIR}/force-bigobj-platform-msvc.patch
        ${_COMPONENT_PATCHES}
)

# Configure LLVM
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        # "-DLLVM_TARGETS_TO_BUILD=${_COMPONENT_TARGETS}"
        ${_COMPONENT_FLAGS}
        -DLLVM_INCLUDE_TESTS=OFF
        -DLLVM_INCLUDE_EXAMPLES=OFF
        -DLLVM_TOOLS_INSTALL_DIR=tools/llvm
)

# Invoke install
vcpkg_install_cmake()

file(GLOB EXE ${CURRENT_PACKAGES_DIR}/bin/*)
file(GLOB DEBUG_EXE ${CURRENT_PACKAGES_DIR}/debug/bin/*)
file(COPY ${EXE} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/llvm)
file(COPY ${DEBUG_EXE} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/llvm)
file(REMOVE ${EXE})
file(REMOVE ${DEBUG_EXE})

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/clang TARGET_PATH share/clang)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/llvm)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/llvm)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/tools
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/debug/bin
    ${CURRENT_PACKAGES_DIR}/debug/msbuild-bin
    ${CURRENT_PACKAGES_DIR}/bin
    ${CURRENT_PACKAGES_DIR}/msbuild-bin
    ${CURRENT_PACKAGES_DIR}/tools/msbuild-bin
    ${CURRENT_PACKAGES_DIR}/include/llvm/BinaryFormat/WasmRelocs
)

# Remove one empty include subdirectory if it is indeed empty
file(GLOB MCANALYSISFILES ${CURRENT_PACKAGES_DIR}/include/llvm/MC/MCAnalysis/*)
if(NOT MCANALYSISFILES)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/llvm/MC/MCAnalysis)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/llvm RENAME copyright)
