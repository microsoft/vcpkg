include(CMakeParseArguments)
include(vcpkg_common_functions)

#TODO: compiler-rt does not work with Debug, exclude or patch COMPILER_RT_HAS_MT_FLAG to negation (line 230)

# LLVM documentation recommends always using static library linkage when
#   building with Microsoft toolchain; it's also the default on other platforms
vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_STATIC_CRT)

# Use only release, because debug takes too long and does not work with compiler-rt
set(VCPKG_BUILD_TYPE release)

# Latest version of LLVM
set(LLVM_VERSION "6.0.1")

# Shared patches for LLVM and clang-stage2
set(LLVM_SHARED_PATCHES
    # Patch cmake modules to point to the share folder
    ${CMAKE_CURRENT_LIST_DIR}/install-cmake-modules-to-share.patch

    # Add bigobj for llvm compilation on MSVC
    ${CMAKE_CURRENT_LIST_DIR}/force-bigobj-modules-llvm-options.patch

    # Fix compilation problem on MSVC
    ${CMAKE_CURRENT_LIST_DIR}/force-bigobj-platform-msvc.patch

    # Fixes build of the experimental target Nios2
    # https://github.com/llvm-mirror/llvm/commit/91518dd4d4f19ab723562376e8b1dfe89e5d2770
    ${CMAKE_CURRENT_LIST_DIR}/fix-experimental-target-nios2-build.patch

    # Based on https://github.com/numba/llvmlite/blob/master/conda-recipes/llvm-lto-static.patch
    ${CMAKE_CURRENT_LIST_DIR}/llvm-lto-static.patch
)

# Shared cmake options for compiling LLVM and clang-stage2
set(LLVM_SHARED_CMAKE_OPTS
    # Disable LLVM tests
    -DLLVM_INCLUDE_TESTS=OFF

    # Disable LLVM examples
    -DLLVM_INCLUDE_EXAMPLES=OFF

    # Enable static build
    -DLLVM_BUILD_STATIC=ON

    # Use LLD linker
    -DLLVM_ENABLE_LLD=ON 

    # Bugfix
    "-DCMAKE_CL_SHOWINCLUDES_PREFIX=Note: including file:"
)

# TODO: 
# list(APPEND _COMPONENT_FLAGS "-DLIBOMP_ENABLE_SHARED=OFF")

# TODO: Do better static checking. Allow only for static linage

# Doxygen requires Graphviz (dot) - Add to PATH
# https://ci.appveyor.com/api/buildjobs/w96x513p36twogfm/artifacts/graphviz-windows.zip
# Make Graphviz multiplatform

message (STATUS "LLVM will be build only for release.")

# LLVM can not be compiled for UWP apps
if("${VCPKG_CMAKE_SYSTEM_NAME}" STREQUAL "WindowsStore")
    message(FATAL_ERROR "llvm cannot currently be built for UWP")
endif()

# Check if user specified target
string(FIND "${FEATURES}" "target-" _hasTarget)
if (${_hasTarget} EQUAL -1)
  message(FATAL_ERROR "You need specify one or more targets to build!")
endif()

# A function for downloading LLVM projects
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
    set(${_pkgName}_ARCHIVE "${${_pkgName}_ARCHIVE}" PARENT_SCOPE)
    vcpkg_extract_source_archive("${${_pkgName}_ARCHIVE}" ${SOURCE_PATH}/${VCPKG_LLVM_DL_EXTRACT_TO})  

    set(VCPKG_LLVM_DL_FOLDER_BASE "${SOURCE_PATH}/${VCPKG_LLVM_DL_EXTRACT_TO}")
    set(VCPKG_LLVM_DL_FOLDER_TEST "${VCPKG_LLVM_DL_FOLDER_BASE}/${VCPKG_LLVM_DL_FOLDER_NAME}")
    if(NOT EXISTS ${VCPKG_LLVM_DL_FOLDER_TEST})
        file(RENAME ${VCPKG_LLVM_DL_FOLDER_BASE}/${VCPKG_LLVM_DL_PKG_NAME}-${LLVM_VERSION}.src ${VCPKG_LLVM_DL_FOLDER_TEST})
    endif()  
endfunction(llvm_download)

# Assert function for detecting flags
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
get_filename_component(PYTHON3_PATH "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path(PREPEND ${PYTHON3_PATH})

# Download and extract the main LLVM project
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/llvm-${LLVM_VERSION}.src)
vcpkg_download_distfile(LLVM_ARCHIVE
    URLS "http://releases.llvm.org/${LLVM_VERSION}/llvm-${LLVM_VERSION}.src.tar.xz"
    FILENAME "llvm-${LLVM_VERSION}.src.tar.xz"
    SHA512 cbbb00eb99cfeb4aff623ee1a5ba075e7b5a76fc00c5f9f539ff28c108598f5708a0369d5bd92683def5a20c2fe60cab7827b42d628dbfcc79b57e0e91b84dd9
)

# Extract main LLVM project
vcpkg_extract_source_archive(${LLVM_ARCHIVE})

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

set(_LLVM_ALL_EXPERIMENTAL_TARGETS
    ARC
    AVR
    Nios2
    RISCV
    WebAssembly
)

# An array of component-specific flags used for debug and release builds
set(_COMPONENT_FLAGS "")

# An array of component-specific flags used only for debug build
set(_COMPONENT_DEBUG_FLAGS "")

# An array of component-specific flags used only for release build
set(_COMPONENT_RELEASE_FLAGS "")

# An array of component-specific patches
set(_COMPONENT_PATCHES "")

# An array of build targets
set(_COMPONENT_TARGETS "")

# An array of build experimental targets
set(_COMPONENT_EXPERIMENTAL_TARGETS "")

# Iterate through all user-defined features and parse it
foreach(_feature IN LISTS FEATURES)
    if ("${_feature}" MATCHES "^enable-")
        # Uppercase the feature name and replace "-" with "_"
        string(TOUPPER "${_feature}" _FEATURE)
        string(REPLACE "-" "_" _FEATURE "${_FEATURE}")

        list(APPEND _COMPONENT_FLAGS "-DLLVM_${_FEATURE}=ON")
    elseif ("${_feature}" MATCHES "^target-exp-")
        string(REPLACE "target-exp-" "" _featureValue "${_feature}")
        if ("${_featureValue}" STREQUAL "wasm")
            set(_featureValue "webassembly")
        endif()
        foreach(_TARGETNAME IN LISTS _LLVM_ALL_EXPERIMENTAL_TARGETS)
            string(TOLOWER "${_TARGETNAME}" _targetName)
            if ("${_featureValue}" STREQUAL "${_targetName}")
                list(APPEND _COMPONENT_EXPERIMENTAL_TARGETS "${_TARGETNAME}")
                break()
            endif()
        endforeach()
    elseif ("${_feature}" MATCHES "^target-")
        string(REPLACE "target-" "" _featureValue "${_feature}")
        foreach(_TARGETNAME IN LISTS _LLVM_ALL_TARGETS)
            string(TOLOWER "${_TARGETNAME}" _targetName)
            if ("${_featureValue}" STREQUAL "${_targetName}")
                list(APPEND _COMPONENT_TARGETS "${_TARGETNAME}")
                break()
            endif()
        endforeach()
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
        get_filename_component(SWIG_PATH "${SWIG}" DIRECTORY)
        vcpkg_add_to_path(PREPEND ${SWIG_PATH})

        # Requires python and swig
        string(REPLACE "lldb-python" "" _featureValue "${_feature}")
        find_package (Python${_featureValue} COMPONENTS Development)
        list(APPEND _COMPONENT_FLAGS "-DPYTHON_HOME=${Python${_featureValue}_ROOT_DIR}")
        list(APPEND _COMPONENT_FLAGS "-DLLDB_BUILD_FRAMEWORK=ON")
        list(APPEND _COMPONENT_FLAGS "-DLLDB_RELOCATABLE_PYTHON=ON")
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
        list(APPEND _COMPONENT_FLAGS "-DPOLLY_ENABLE_GPGPU_CODEGEN=ON")
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
        vcpkg_add_to_path(PREPEND ${PERL_PATH})

        # If libomp-ompt-off is defined, that will be ignored
        list(APPEND _COMPONENT_FLAGS "-DLIBOMP_OMPT_OPTIONAL=ON")

        message(STATUS "Warning: On Windows platform libomp does not support static linkage. ")
        list(APPEND _COMPONENT_FLAGS "-DLIBOMP_ENABLE_SHARED=ON")
    elseif ("${_feature}" MATCHES "^libomp-")
        string(REPLACE "libomp-" "" _featureValue "${_feature}")

        if ("${_featureValue}" STREQUAL "debugger")
            list(APPEND _COMPONENT_FLAGS "-DLIBOMP_USE_DEBUGGER=ON")

            # The USE_DEBUGGER is defined in the kmp.h header
            # that's why the kmp_debugger can not be found.
            # So I moved it just a little bit down.
            list(APPEND _COMPONENT_PATCHES "${CMAKE_CURRENT_LIST_DIR}/openmp-kmp-debugger.patch")
        elseif ("${_featureValue}" STREQUAL "stats")
            if ("${VCPKG_CMAKE_SYSTEM_NAME}" STREQUAL "")
                message(FATAL_ERROR "The stats-gathering code does not work with Visual Studo compiler yet.")
            else()
                list(APPEND _COMPONENT_FLAGS "-DLIBOMP_STATS=ON")
            endif()
        elseif ("${_featureValue}" STREQUAL "ompt-off")
            list(APPEND _COMPONENT_FLAGS "-DLIBOMP_OMPT_SUPPORT=OFF")
        endif()
    elseif ("${_feature}" STREQUAL "documentation")
        vcpkg_find_acquire_program(DOXYGEN)
        get_filename_component(DOXYGEN_PATH ${DOXYGEN} DIRECTORY)
        vcpkg_add_to_path(PREPEND ${DOXYGEN_PATH})
        list(APPEND _COMPONENT_FLAGS "-DLLVM_BUILD_DOCS=ON")
        list(APPEND _COMPONENT_FLAGS "-DLLVM_INCLUDE_DOCS=ON")
    endif()
endforeach()

# If the "all" target is defined in FEATURES, replace _COMPONENT_TARGETS
if ("all" IN_LIST _COMPONENT_TARGETS OR "target-all" IN_LIST FEATURES)
    set(_COMPONENT_TARGETS "all")
endif()

# If the "all" target is defined in FEATURES, replace _COMPONENT_EXPERIMENTAL_TARGETS
if ("target-exp-all" IN_LIST FEATURES)
    set(_COMPONENT_EXPERIMENTAL_TARGETS "${_LLVM_ALL_EXPERIMENTAL_TARGETS}")
endif()

# Set ENV for LLVM_TARGETS_TO_BUILD, defaultly don't build any
set(ENV{LLVM_TARGETS_TO_BUILD} "${_COMPONENT_TARGETS}")

# Set EVN for LLVM_EXPERIMENTAL_TARGETS_TO_BUILD if any defined
if (NOT "${_COMPONENT_EXPERIMENTAL_TARGETS}" STREQUAL "")
    set(ENV{LLVM_EXPERIMENTAL_TARGETS_TO_BUILD} "${_COMPONENT_EXPERIMENTAL_TARGETS}")
endif()

# Appyl patches
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        # Patch LLVM
        ${LLVM_SHARED_PATCHES}

        # Add patch for settings LLVM_TARGETS_TO_BUILD, LLVM_EXPERIMENTAL_TARGETS_TO_BUILD from ENV
        ${CMAKE_CURRENT_LIST_DIR}/llvm-set-using-env.patch

        # Component-specific patches
        ${_COMPONENT_PATCHES}
)

#LLVM_BUILD_EXTERNAL_COMPILER_RT

if ("clang-stage2" IN_LIST FEATURES)
    set(CLANG_STAGE2_BASE_SRC_DIR ${CURRENT_BUILDTREES_DIR}/src/stage2)
    set(CLANG_STAGE2_SRC_DIR ${CLANG_STAGE2_BASE_SRC_DIR}/llvm-${LLVM_VERSION}.src)
    set(CLANG_STAGE2_DIR ${CURRENT_BUILDTREES_DIR}/stage2-${TARGET_TRIPLET})
    set(CLANG_STAGE2_DONE "${CLANG_STAGE2_DIR}/done")

    if (NOT EXISTS ${CLANG_STAGE2_DONE})
        # Extract main LLVM project
        vcpkg_extract_source_archive(${LLVM_ARCHIVE} ${CLANG_STAGE2_BASE_SRC_DIR})

        # Extract clang project
        vcpkg_extract_source_archive(${CLANG_ARCHIVE} ${CLANG_STAGE2_SRC_DIR}/tools)
        file(RENAME ${CLANG_STAGE2_SRC_DIR}/tools/cfe-${LLVM_VERSION}.src ${CLANG_STAGE2_SRC_DIR}/tools/clang)

        # Appyl patches
        vcpkg_apply_patches(
            SOURCE_PATH ${CLANG_STAGE2_SRC_DIR}
            PATCHES ${LLVM_SHARED_PATCHES}
        )

        message(STATUS "---- Building Clang stage2 compiler.")

        # -DCMAKE_C_COMPILER="PATH to the C" -DCMAKE_CXX_COMPILER="PATH to the C++"
        #TODO: Change compiler?!
        #set CC=..\build32_stage0\bin\clang-cl
        #set CXX=..\build32_stage0\bin\clang-cl
        # 

        #list( _COMPONENT_FLAGS "-DLIBUNWIND_ENABLE_STATIC=ON")

        message(STATUS "---- Configure clang-stage2...")
        # Prepare stage2 compiler for release
        file(MAKE_DIRECTORY ${CLANG_STAGE2_DIR})
        vcpkg_execute_required_process(
            COMMAND cmake -G Ninja ${LLVM_SHARED_CMAKE_OPTS} -DCMAKE_BUILD_TYPE=MINSIZEREL -DCLANG_ENABLE_BOOTSTRAP=ON ${CLANG_STAGE2_SRC_DIR}
            WORKING_DIRECTORY ${CLANG_STAGE2_DIR}
            LOGNAME config-stage2-${TARGET_TRIPLET}
        )

        message(STATUS "---- Building clang-stage2...")
        # Build stage2 compiler for release
        vcpkg_execute_required_process(
            COMMAND ninja stage2
            WORKING_DIRECTORY ${CLANG_STAGE2_DIR}
            LOGNAME build-stage2-${TARGET_TRIPLET}
        )
        file(TOUCH "${CLANG_STAGE2_DIR}/done")
    else()
        message(STATUS "The clang-stage2 is already compiled.")
    endif()

    list(APPEND _COMPONENT_FLAGS "-DCMAKE_CXX_COMPILER=${CLANG_STAGE2_DIR}/tools/clang/stage2-bins/bin/clang-cl.exe")
    list(APPEND _COMPONENT_FLAGS "-DCMAKE_C_COMPILER=${CLANG_STAGE2_DIR}/tools/clang/stage2-bins/bin/clang-cl.exe")
    list(APPEND _COMPONENT_FLAGS "-DCMAKE_ASM_COMPILER=${CLANG_STAGE2_DIR}/tools/clang/stage2-bins/bin/clang-cl.exe")
    # use stage2 compiler for compiling the project.
endif()

# Configure LLVM
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        # Use shared cmake options
        ${LLVM_SHARED_CMAKE_OPTS}

        -DCLANG_ENABLE_BOOTSTRAP=ON

        # Change tool installation directory
        -DLLVM_TOOLS_INSTALL_DIR=tools/llvm

        # Component-specific compilation flags for debug and release
        ${_COMPONENT_FLAGS}

    OPTIONS_RELEASE
        # Component-specific compilation flags for release only
        ${_COMPONENT_RELEASE_FLAGS}

    OPTIONS_DEBUG
        # Component-specific compilation flags for debug only
        ${_COMPONENT_DEBUG_FLAGS}
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
