# Clang
#
# The MDL SDK includes a vendored copy of a specific LLVM version, to generate
# JIT code at runtime for various backends. This code needs to be linked with
# parts that are precompiled at build time. This precompilation step needs a
# matching clang compiler.
#
# This port provides CMake instructions to fetch clang and use it to build this
# port. It will not be installed, and is not usable by other ports.

# There are no MacOS binaries for 12.0.1, use 12.0.0 instead.
if(VCPKG_HOST_IS_OSX)
    set(LLVM_VERSION 12.0.0)
else()
    set(LLVM_VERSION 12.0.1)
endif()

set(LLVM_BASE_URL "https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}")

if(VCPKG_HOST_IS_WINDOWS AND (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64"))
    set(LLVM_FILENAME  "LLVM-${LLVM_VERSION}-win64.exe")
    set(LLVM_HASH      733bfb425af2e7e4f187fca6d9cfdf7ecc9aa846ef2c227d57fad7cc67d114bde27e49385df362cb399c4aa0e2d481890e2148756a18925b0229ad516a9f8bb4)
elseif(VCPKG_HOST_IS_LINUX AND (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64"))
    set(LLVM_FILENAME  "clang+llvm-${LLVM_VERSION}-x86_64-linux-gnu-ubuntu-16.04.tar.xz")
    set(LLVM_HASH      6f1eb4ef9885ea7ce56581000e42595f72be37901c213377c8716d160b84441fd017a0a062b188e574a6873b320d3bf2c850beb9822cf4c0025c543effb37a00)
elseif(VCPKG_HOST_IS_LINUX AND (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64"))
    set(LLVM_FILENAME  "clang+llvm-${LLVM_VERSION}-aarch64-linux-gnu.tar.xz")
    set(LLVM_HASH      7a979641def7d575bf5c9dbc0343212b31d840e65b06b89fcdf37e7835c56ba8d695a6508f13516eecc3a0ea87409e548993c64265a700e83789c9c5c8d1f88b)
elseif(VCPKG_HOST_IS_OSX AND (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64"))
    set(LLVM_FILENAME  "clang+llvm-${LLVM_VERSION}-x86_64-apple-darwin.tar.xz")
    set(LLVM_HASH      2e74791425c12dacc201c5cfc38be7abe0ac670ddb079e75d477bf3f78d1dad442d1b4c819d67e0ba51c4474d8b7a726d4c50b7ad69d536e30edc38d1dce78b8)
else()
    message(FATAL_ERROR "Pre-built binaries for Clang ${LLVM_VERSION} not available, aborting install.")
endif()

vcpkg_download_distfile(LLVM_ARCHIVE_PATH
    URLS     "${LLVM_BASE_URL}/${LLVM_FILENAME}"
    SHA512   ${LLVM_HASH}
    FILENAME "${LLVM_FILENAME}"
)

if(VCPKG_TARGET_IS_WINDOWS)
    get_filename_component(LLVM_BASENAME "${LLVM_FILENAME}" NAME_WE)
    set(LLVM_DIRECTORY "${CURRENT_BUILDTREES_DIR}/src/${LLVM_BASENAME}")
    file(REMOVE_RECURSE "${LLVM_DIRECTORY}")
    file(MAKE_DIRECTORY "${LLVM_DIRECTORY}")

    vcpkg_find_acquire_program(7Z)
    vcpkg_execute_in_download_mode(
        COMMAND ${7Z} x "${LLVM_ARCHIVE_PATH}" "-o${LLVM_DIRECTORY}" -y -bso0 -bsp0
        WORKING_DIRECTORY "${LLVM_DIRECTORY}"
    )
else()
    vcpkg_extract_source_archive(LLVM_DIRECTORY
        ARCHIVE "${LLVM_ARCHIVE_PATH}"
        SOURCE_BASE "clang+llvm-${LLVM_VERSION}"
    )
endif()

set(LLVM_CLANG "${LLVM_DIRECTORY}/bin/clang${VCPKG_HOST_EXECUTABLE_SUFFIX}")
if(NOT EXISTS "${LLVM_CLANG}")
    message(FATAL_ERROR "Missing required build tool clang ${LLVM_VERSION}, please check your setup.")
endif()



# MDL-SDK
#
# Note about "supports:" in vcpkg.json:
# !x86, !(windows & (arm | uwp)), !android: not supported by the MDL SDK
# !(osx & arm): no precompiled clang 12 binaries available

# Required for plugins.
set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/MDL-SDK
    REF "${VERSION}"
    SHA512 4b53c9aba2f1fd6658ad6c017fd1643be0f60dc9beedaadd95a5dc417133440ee164f5e8e563f9dfaeb93749e0cf623e2e1b4a9ec3d5a939d0990de5e01a6464
    HEAD_REF release/2024.1
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dds           MDL_BUILD_DDS_PLUGIN
        openimageio   MDL_BUILD_OPENIMAGEIO_PLUGIN
)

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(MSVC_RUNTIME_OPTION "-DMDL_MSVC_DYNAMIC_RUNTIME:BOOL=OFF")
    else()
        set(MSVC_RUNTIME_OPTION "-DMDL_MSVC_DYNAMIC_RUNTIME:BOOL=ON")
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMDL_LOG_DEPENDENCIES:BOOL=ON
        -DMDL_BUILD_SDK:BOOL=ON
        -DMDL_BUILD_SDK_EXAMPLES:BOOL=OFF
        -DMDL_BUILD_CORE_EXAMPLES:BOOL=OFF
        -DMDL_BUILD_DOCUMENTATION:BOOL=OFF
        -DMDL_BUILD_ARNOLD_PLUGIN:BOOL=OFF
        -DMDL_ENABLE_UNIT_TESTS:BOOL=OFF
        -DMDL_ENABLE_PYTHON_BINDINGS:BOOL=OFF
        -DMDL_TREAT_RUNTIME_DEPS_AS_BUILD_DEPS:BOOL=OFF
        ${FEATURE_OPTIONS}
        ${MSVC_RUNTIME_OPTION}
        -Dpython_PATH:PATH=${PYTHON3}
        -Dclang_PATH:PATH=${LLVM_CLANG}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_copy_tools(
    TOOL_NAMES i18n mdl_distiller_cli mdlc mdlm mdltlc
    AUTO_CLEAN
)

vcpkg_cmake_config_fixup(PACKAGE_NAME "mdl")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/doc"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/doc"
)

# install usage file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# merge all license files into copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(READ "${SOURCE_PATH}/LICENSE_IMAGES.md" _images)
file(APPEND "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "\n\n${_images}")
file(READ "${SOURCE_PATH}/LICENSE_THIRD_PARTY.md" _third_party)
file(APPEND "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "\n\n${_third_party}")
