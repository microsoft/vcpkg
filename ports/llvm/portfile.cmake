include(vcpkg_common_functions)

set(VERSION "10.0.0")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO llvm/llvm-project
    REF llvmorg-10.0.0-rc5
    SHA512 d1fd91663e76474cd375670b7bcadede45dc0b4ffa7b02bad541f22c861f8fd1995f793332cd8df3b56eb40f8947b18ba29e72c064bf8022f8bd4914da63a31b
    HEAD_REF master
    PATCHES
        0001-allow-to-use-commas.patch
        0002-fix-install-paths.patch
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
    list(APPEND FEATURE_OPTIONS
        # Disable install the scan-build tool
        -DCLANG_INSTALL_SCANBUILD=OFF
        # Disable install the scan-view tool
        -DCLANG_INSTALL_SCANVIEW=OFF
    )
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

# Use comma-separated string for enabled projects instead of semicolon-separated string.
# See issue https://github.com/microsoft/vcpkg/issues/4320
string(REPLACE ";" "," LLVM_ENABLE_PROJECTS "${LLVM_ENABLE_PROJECTS}")

vcpkg_find_acquire_program(PYTHON3)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/llvm
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLLVM_INCLUDE_EXAMPLES=OFF
        -DLLVM_BUILD_EXAMPLES=OFF
        # LLVM generates CMake error due to Visual Studio version 16.4 is known to miscompile part of LLVM.
        # LLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=ON disables this error.
        # See https://developercommunity.visualstudio.com/content/problem/845933/miscompile-boolean-condition-deduced-to-be-always.html
        -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=ON
        -DLLVM_ENABLE_PROJECTS=${LLVM_ENABLE_PROJECTS}
        -DPACKAGE_VERSION=${VERSION}
        -DPYTHON_EXECUTABLE=${PYTHON3}
        # Limit the maximum number of concurrent link jobs to 1. This should fix low amount of memory issue for link.
        -DLLVM_PARALLEL_LINK_JOBS=1
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/llvm)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/clang TARGET_PATH share/clang)

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(GLOB_RECURSE _release_targets
        "${CURRENT_PACKAGES_DIR}/share/llvm/*-release.cmake"
        "${CURRENT_PACKAGES_DIR}/share/clang/*-release.cmake"
    )
    # LLVM tools should be located in the bin folder because llvm-config expects to be inside a bin dir.
    foreach(_target IN LISTS _release_targets)
        file(READ ${_target} _contents)
        # Rename `/tools/${PORT}` to `/bin` back because there is no way to avoid this in vcpkg_fixup_cmake_targets.
        string(REPLACE "{_IMPORT_PREFIX}/tools/${PORT}" "{_IMPORT_PREFIX}/bin" _contents "${_contents}")
        file(WRITE ${_target} "${_contents}")
    endforeach()
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(GLOB_RECURSE _debug_targets
        "${CURRENT_PACKAGES_DIR}/share/llvm/*-debug.cmake"
        "${CURRENT_PACKAGES_DIR}/share/clang/*-debug.cmake"
        )
    # LLVM tools should be located in the bin folder because llvm-config expects to be inside a bin dir.
    foreach(_target IN LISTS _debug_targets)
        file(READ ${_target} _contents)
        # Rename `/debug/tools/${PORT}` to `debug/bin` back because there is no way to avoid this in vcpkg_fixup_cmake_targets.
        string(REPLACE "{_IMPORT_PREFIX}/debug/tools/${PORT}" "{_IMPORT_PREFIX}/debug/bin" _contents "${_contents}")
        file(WRITE ${_target} "${_contents}")
    endforeach()
endif()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/llvm/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/llvm RENAME copyright)
if("clang" IN_LIST FEATURES)
    file(INSTALL ${SOURCE_PATH}/clang/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/clang RENAME copyright)
endif()

# Don't fail if the bin folder exists.
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
