vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/getsentry/sentry-native/releases/download/${VERSION}/sentry-native.zip"
    FILENAME "sentry-native-${VERSION}.zip"
    SHA512 d2f56774c720db46f82b374c196cf96cfa5aaf9e3ed067e1e8aaa369f23baf322c75b3085782e9613ec419436e9484f140c07973ce9b5cd42047344b5911fde8
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
    PATCHES
        fix-crashpad-wer.patch
        fix-usage-runtime.patch
        fix-cmake4.patch
)
file(REMOVE_RECURSE "${SOURCE_PATH}/external/crashpad/third_party/zlib/zlib")

vcpkg_list(SET options)

if(NOT "backend" IN_LIST FEATURES)
    vcpkg_list(APPEND options "-DSENTRY_BACKEND=none")
elseif("wer" IN_LIST FEATURES)
    vcpkg_list(APPEND options "-DSENTRY_BACKEND=crashpad")
elseif(DEFINED SENTRY_BACKEND)
    # Legacy, possible override from triplet, but cannot handle dependencies
    vcpkg_list(APPEND options "-DSENTRY_BACKEND=${SENTRY_BACKEND}")
endif()

if(NOT "transport" IN_LIST FEATURES)
    vcpkg_list(APPEND options "-DSENTRY_TRANSPORT=none")
endif()

if("wer" IN_LIST FEATURES)
    vcpkg_list(APPEND options "-DSENTRY_TRANSPORT_CRASHPAD_USE_WER=ON")
endif()

if("compression" IN_LIST FEATURES)
    vcpkg_list(APPEND options "-DSENTRY_TRANSPORT_COMPRESSION=ON")
endif()

# sentry-native only looks for pkg-config on Linux, to locate the system libunwind for
# SENTRY_LIBUNWIND_SYSTEM. Acquire it directly instead of depending on the pkgconf port.
if(VCPKG_TARGET_IS_LINUX)
    vcpkg_find_acquire_program(PKGCONFIG)
    vcpkg_list(APPEND options "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}")
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(VCPKG_CXX_FLAGS "/D_CRT_DECLARE_NONSTDC_NAMES ${VCPKG_CXX_FLAGS}")
    set(VCPKG_C_FLAGS "/D_CRT_DECLARE_NONSTDC_NAMES ${VCPKG_C_FLAGS}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
        -DSENTRY_BUILD_TESTS=OFF
        -DSENTRY_BUILD_EXAMPLES=OFF
        -DCRASHPAD_ZLIB_SYSTEM=ON
        -DSENTRY_LIBUNWIND_SYSTEM=ON
    MAYBE_UNUSED_VARIABLES
        CRASHPAD_ZLIB_SYSTEM
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/sentry.h"
        "#define SENTRY_H_INCLUDED"
        "#define SENTRY_H_INCLUDED\n\n#define SENTRY_BUILD_STATIC"
    )
endif()

vcpkg_cmake_config_fixup(PACKAGE_NAME sentry CONFIG_PATH lib/cmake/sentry)

if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/crashpad_handler${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    vcpkg_copy_tools(TOOL_NAMES crashpad_handler AUTO_CLEAN)
endif()

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/vendor/mpack.h"
        "${SOURCE_PATH}/vendor/stb_sprintf.h"
        "${SOURCE_PATH}/external/libunwindstack-ndk/LICENSE"
        "${SOURCE_PATH}/external/crashpad/LICENSE"
        "${SOURCE_PATH}/external/crashpad/third_party/getopt/LICENSE"
        "${SOURCE_PATH}/external/crashpad/third_party/lss/lss/LICENSE"
        "${SOURCE_PATH}/external/crashpad/third_party/mini_chromium/mini_chromium/LICENSE"
        "${SOURCE_PATH}/external/crashpad/third_party/mini_chromium/mini_chromium/base/third_party/icu/LICENSE"
        "${SOURCE_PATH}/external/crashpad/third_party/mpack/LICENSE"
)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
