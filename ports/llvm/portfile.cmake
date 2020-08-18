set(VERSION "10.0.0")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO llvm/llvm-project
    REF llvmorg-10.0.0
    SHA512 baa182d62fef1851836013ae8a1a00861ea89769778d67fb97b407a9de664e6c85da2af9c5b3f75d2bf34ff6b00004e531ca7e4b3115a26c0e61c575cf2303a0
    HEAD_REF master
    PATCHES
        0001-allow-to-use-commas.patch
        0002-fix-install-paths.patch
        0003-fix-vs2019-v16.6.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    tools LLVM_BUILD_TOOLS
    tools LLVM_INCLUDE_TOOLS
    utils LLVM_BUILD_UTILS
    utils LLVM_INCLUDE_UTILS
    enable-rtti LLVM_ENABLE_RTTI
)

# By default assertions are enabled for Debug configuration only.
if("enable-assertions" IN_LIST FEATURES)
    # Force enable assertions for all configurations.
    list(APPEND FEATURE_OPTIONS
        -DLLVM_ENABLE_ASSERTIONS=ON
    )
elseif("disable-assertions" IN_LIST FEATURES)
    # Force disable assertions for all configurations.
    list(APPEND FEATURE_OPTIONS
        -DLLVM_ENABLE_ASSERTIONS=OFF
    )
endif()

# LLVM_ABI_BREAKING_CHECKS can be WITH_ASSERTS (default), FORCE_ON or FORCE_OFF.
# By default abi-breaking checks are enabled if assertions are enabled.
if("enable-abi-breaking-checks" IN_LIST FEATURES)
    # Force enable abi-breaking checks.
    list(APPEND FEATURE_OPTIONS
        -DLLVM_ABI_BREAKING_CHECKS=FORCE_ON
    )
elseif("disable-abi-breaking-checks" IN_LIST FEATURES)
    # Force disable abi-breaking checks.
    list(APPEND FEATURE_OPTIONS
        -DLLVM_ABI_BREAKING_CHECKS=FORCE_OFF
    )
endif()

set(LLVM_ENABLE_PROJECTS)
if("clang" IN_LIST FEATURES OR "clang-tools-extra" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_PROJECTS "clang")
    if("disable-clang-static-analyzer" IN_LIST FEATURES)
        list(APPEND FEATURE_OPTIONS
            # Disable ARCMT
            -DCLANG_ENABLE_ARCMT=OFF
            # Disable static analyzer
            -DCLANG_ENABLE_STATIC_ANALYZER=OFF
        )
    endif()
    if(VCPKG_TARGET_IS_WINDOWS)
        list(APPEND FEATURE_OPTIONS
            # Disable dl library on Windows
            -DDL_LIBRARY_PATH:FILEPATH=
        )
    endif()
endif()
if("clang-tools-extra" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_PROJECTS "clang-tools-extra")
endif()
if("compiler-rt" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_PROJECTS "compiler-rt")
endif()
if("lld" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_PROJECTS "lld")
endif()
if("openmp" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_PROJECTS "openmp")
    # Perl is required for the OpenMP run-time
    vcpkg_find_acquire_program(PERL)
    list(APPEND FEATURE_OPTIONS
        -DPERL_EXECUTABLE=${PERL}
    )
endif()
if("lldb" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_PROJECTS "lldb")
endif()
if("polly" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_PROJECTS "polly")
endif()

set(LLVM_TARGETS_TO_BUILD)
if("target-all" IN_LIST FEATURES)
    set(LLVM_TARGETS_TO_BUILD "all")
else()
    if("target-aarch64" IN_LIST FEATURES)
        list(APPEND LLVM_TARGETS_TO_BUILD "AArch64")
    endif()
    if("target-amdgpu" IN_LIST FEATURES)
        list(APPEND LLVM_TARGETS_TO_BUILD "AMDGPU")
    endif()
    if("target-arm" IN_LIST FEATURES)
        list(APPEND LLVM_TARGETS_TO_BUILD "ARM")
    endif()
    if("target-bpf" IN_LIST FEATURES)
        list(APPEND LLVM_TARGETS_TO_BUILD "BPF")
    endif()
    if("target-hexagon" IN_LIST FEATURES)
        list(APPEND LLVM_TARGETS_TO_BUILD "Hexagon")
    endif()
    if("target-lanai" IN_LIST FEATURES)
        list(APPEND LLVM_TARGETS_TO_BUILD "Lanai")
    endif()
    if("target-mips" IN_LIST FEATURES)
        list(APPEND LLVM_TARGETS_TO_BUILD "Mips")
    endif()
    if("target-msp430" IN_LIST FEATURES)
        list(APPEND LLVM_TARGETS_TO_BUILD "MSP430")
    endif()
    if("target-nvptx" IN_LIST FEATURES)
        list(APPEND LLVM_TARGETS_TO_BUILD "NVPTX")
    endif()
    if("target-powerpc" IN_LIST FEATURES)
        list(APPEND LLVM_TARGETS_TO_BUILD "PowerPC")
    endif()
    if("target-riscv" IN_LIST FEATURES)
        list(APPEND LLVM_TARGETS_TO_BUILD "RISCV")
    endif()
    if("target-sparc" IN_LIST FEATURES)
        list(APPEND LLVM_TARGETS_TO_BUILD "Sparc")
    endif()
    if("target-systemz" IN_LIST FEATURES)
        list(APPEND LLVM_TARGETS_TO_BUILD "SystemZ")
    endif()
    if("target-webassembly" IN_LIST FEATURES)
        list(APPEND LLVM_TARGETS_TO_BUILD "WebAssembly")
    endif()
    if("target-x86" IN_LIST FEATURES)
        list(APPEND LLVM_TARGETS_TO_BUILD "X86")
    endif()
    if("target-xcore" IN_LIST FEATURES)
        list(APPEND LLVM_TARGETS_TO_BUILD "XCore")
    endif()
endif()

# Detect target to build if not specified
if("${LLVM_TARGETS_TO_BUILD}" STREQUAL "")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(LLVM_TARGETS_TO_BUILD "X86")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        set(LLVM_TARGETS_TO_BUILD "ARM")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(LLVM_TARGETS_TO_BUILD "AArch64")
    else()
        set(LLVM_TARGETS_TO_BUILD "all")
    endif()
endif()

# Use comma-separated string instead of semicolon-separated string.
# See https://github.com/microsoft/vcpkg/issues/4320
string(REPLACE ";" "," LLVM_ENABLE_PROJECTS "${LLVM_ENABLE_PROJECTS}")
string(REPLACE ";" "," LLVM_TARGETS_TO_BUILD "${LLVM_TARGETS_TO_BUILD}")

vcpkg_find_acquire_program(PYTHON3)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/llvm
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLLVM_INCLUDE_EXAMPLES=OFF
        -DLLVM_BUILD_EXAMPLES=OFF
        -DLLVM_INCLUDE_TESTS=OFF
        -DLLVM_BUILD_TESTS=OFF
        # Disable optional dependencies to libxml2 and zlib
        -DLLVM_ENABLE_LIBXML2=OFF
        -DLLVM_ENABLE_ZLIB=OFF
        # Force TableGen to be built with optimization. This will significantly improve build time.
        -DLLVM_OPTIMIZED_TABLEGEN=ON
        # LLVM generates CMake error due to Visual Studio version 16.4 is known to miscompile part of LLVM.
        # LLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=ON disables this error.
        # See https://developercommunity.visualstudio.com/content/problem/845933/miscompile-boolean-condition-deduced-to-be-always.html
        -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=ON
        -DLLVM_ENABLE_PROJECTS=${LLVM_ENABLE_PROJECTS}
        -DLLVM_TARGETS_TO_BUILD=${LLVM_TARGETS_TO_BUILD}
        -DPACKAGE_VERSION=${VERSION}
        -DPYTHON_EXECUTABLE=${PYTHON3}
        # Limit the maximum number of concurrent link jobs to 1. This should fix low amount of memory issue for link.
        -DLLVM_PARALLEL_LINK_JOBS=1
        # Disable build LLVM-C.dll (Windows only) due to doesn't compile with CMAKE_DEBUG_POSTFIX
        -DLLVM_BUILD_LLVM_C_DYLIB=OFF
        -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/${PORT})
if("clang" IN_LIST FEATURES)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/clang TARGET_PATH share/clang)
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(GLOB_RECURSE _llvm_release_targets
        "${CURRENT_PACKAGES_DIR}/share/llvm/*-release.cmake"
    )
    set(_clang_release_targets)
    if("clang" IN_LIST FEATURES)
        file(GLOB_RECURSE _clang_release_targets
            "${CURRENT_PACKAGES_DIR}/share/clang/*-release.cmake"
        )
    endif()
    foreach(_target IN LISTS _llvm_release_targets _clang_release_targets)
        file(READ ${_target} _contents)
        # LLVM tools should be located in the bin folder because llvm-config expects to be inside a bin dir.
        # Rename `/tools/${PORT}` to `/bin` back because there is no way to avoid this in vcpkg_fixup_cmake_targets.
        string(REPLACE "{_IMPORT_PREFIX}/tools/${PORT}" "{_IMPORT_PREFIX}/bin" _contents "${_contents}")
        file(WRITE ${_target} "${_contents}")
    endforeach()
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(GLOB_RECURSE _llvm_debug_targets
        "${CURRENT_PACKAGES_DIR}/share/llvm/*-debug.cmake"
    )
    set(_clang_debug_targets)
    if("clang" IN_LIST FEATURES)
        file(GLOB_RECURSE _clang_debug_targets
            "${CURRENT_PACKAGES_DIR}/share/clang/*-debug.cmake"
        )
    endif()
    foreach(_target IN LISTS _llvm_debug_targets _clang_debug_targets)
        file(READ ${_target} _contents)
        # LLVM tools should be located in the bin folder because llvm-config expects to be inside a bin dir.
        # Rename `/tools/${PORT}` to `/bin` back because there is no way to avoid this in vcpkg_fixup_cmake_targets.
        string(REPLACE "{_IMPORT_PREFIX}/tools/${PORT}" "{_IMPORT_PREFIX}/bin" _contents "${_contents}")
        # Debug shared libraries should have `d` suffix and should be installed in the `/bin` directory.
        # Rename `/debug/bin/` to `/bin`
        string(REPLACE "{_IMPORT_PREFIX}/debug/bin/" "{_IMPORT_PREFIX}/bin/" _contents "${_contents}")
        file(WRITE ${_target} "${_contents}")
    endforeach()

    # Install debug shared libraries in the `/bin` directory
    file(GLOB _debug_shared_libs ${CURRENT_PACKAGES_DIR}/debug/bin/*${CMAKE_SHARED_LIBRARY_SUFFIX})
    file(INSTALL ${_debug_shared_libs} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/debug/bin
        ${CURRENT_PACKAGES_DIR}/debug/include
        ${CURRENT_PACKAGES_DIR}/debug/share
    )
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/llvm/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
if("clang" IN_LIST FEATURES)
    file(INSTALL ${SOURCE_PATH}/clang/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/clang RENAME copyright)
endif()

# Don't fail if the bin folder exists.
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
