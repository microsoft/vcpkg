include(vcpkg_common_functions)

set(VERSION "10.0.0")

# LLVM documentation recommends always using static library linkage when
# building with Microsoft toolchain; it's also the default on other platforms
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO llvm/llvm-project
    REF 001c8aac80e3924c33a4cc644cca58401c72fe6b
    SHA512 f25384a1005f037c77a9654019699ea08079585e05f33c8eda29c26456c24d5e88dbb634e7ac1f0ccb939acc625819e12f47fdbb21633f2725e4574f951109ca
    HEAD_REF master
    PATCHES
        0001-allow-to-use-commas.patch
        0002-fix-install-paths.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    tools LLVM_BUILD_TOOLS
    tools LLVM_INCLUDE_TOOLS
    enable-rtti LLVM_ENABLE_RTTI
)

set(LLVM_ENABLE_PROJECTS)
if("clang" IN_LIST FEATURES OR "clang-tools-extra" IN_LIST FEATURES)
    list(APPEND LLVM_ENABLE_PROJECTS "clang")
    list(APPEND FEATURE_OPTIONS
        # Disable install the scan-build tool
        -DCLANG_INSTALL_SCANBUILD=OFF
        # Disable install the scan-view tool
        -DCLANG_INSTALL_SCANVIEW=OFF
        -DCLANG_TOOLS_INSTALL_DIR=tools/${PORT}
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
    list(APPEND FEATURE_OPTIONS
        -DLLD_TOOLS_INSTALL_DIR=tools/${PORT}
    )
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
    list(APPEND FEATURE_OPTIONS
        -DLLDB_TOOLS_INSTALL_DIR=tools/${PORT}
    )
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
        -DLLVM_TOOLS_INSTALL_DIR=tools/${PORT}
        -DPACKAGE_VERSION=${VERSION}
        -DPYTHON_EXECUTABLE=${PYTHON3}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/llvm)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/clang TARGET_PATH share/clang)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(READ ${CURRENT_PACKAGES_DIR}/share/clang/ClangTargets-release.cmake RELEASE_MODULE)
    string(REPLACE "\${_IMPORT_PREFIX}/bin" "\${_IMPORT_PREFIX}/tools/${PORT}" RELEASE_MODULE "${RELEASE_MODULE}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/clang/ClangTargets-release.cmake "${RELEASE_MODULE}")

    file(READ ${CURRENT_PACKAGES_DIR}/share/${PORT}/LLVMExports-release.cmake RELEASE_MODULE)
    string(REPLACE "\${_IMPORT_PREFIX}/bin" "\${_IMPORT_PREFIX}/tools/${PORT}" RELEASE_MODULE "${RELEASE_MODULE}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/LLVMExports-release.cmake "${RELEASE_MODULE}")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(READ ${CURRENT_PACKAGES_DIR}/share/clang/ClangTargets-debug.cmake DEBUG_MODULE)
    string(REPLACE "\${_IMPORT_PREFIX}/debug/bin" "\${_IMPORT_PREFIX}/tools/${PORT}" DEBUG_MODULE "${DEBUG_MODULE}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/clang/ClangTargets-debug.cmake "${DEBUG_MODULE}")

    file(READ ${CURRENT_PACKAGES_DIR}/share/${PORT}/LLVMExports-debug.cmake DEBUG_MODULE)
    string(REPLACE "\${_IMPORT_PREFIX}/debug/bin" "\${_IMPORT_PREFIX}/tools/${PORT}" DEBUG_MODULE "${DEBUG_MODULE}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/LLVMExports-debug.cmake "${DEBUG_MODULE}")
endif()

if (EXISTS ${CURRENT_PACKAGES_DIR}/share/${PORT}/LLVMConfig.cmake)
    file(READ ${CURRENT_PACKAGES_DIR}/share/${PORT}/LLVMConfig.cmake LLVM_TOOLS_MODULE)
    string(REPLACE "\${LLVM_INSTALL_PREFIX}/bin" "\${LLVM_INSTALL_PREFIX}/tools/${PORT}" LLVM_TOOLS_MODULE "${LLVM_TOOLS_MODULE}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/LLVMConfig.cmake "${LLVM_TOOLS_MODULE}")
endif()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/bin
    ${CURRENT_PACKAGES_DIR}/debug/bin
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/debug/tools
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/llvm/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/llvm RENAME copyright)
if("clang" IN_LIST FEATURES)
    file(INSTALL ${SOURCE_PATH}/clang/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/clang RENAME copyright)
endif()
