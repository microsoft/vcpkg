vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/getsentry/sentry-native/releases/download/0.5.2/sentry-native.zip"
    FILENAME "sentry-native-0.5.2.zip"
    SHA512 bbeff94c6795be737d1aee99a061dfb863eca5abbc2797b2bb4a2903354b25787f4808694bf24eee9bdeb419eeae7f6e4f236b7eb95bcb1d3821ad799d322f54
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
    PATCHES
        fix-warningC5105.patch
        fix-config-cmake.patch
        use-zlib-target.patch
)

if (NOT DEFINED SENTRY_BACKEND)
    if(MSVC AND CMAKE_GENERATOR_TOOLSET MATCHES "_xp$")
        set(SENTRY_BACKEND "breakpad")
    elseif(APPLE OR WIN32)
        set(SENTRY_BACKEND "crashpad")
    elseif(LINUX)
        set(SENTRY_BACKEND "breakpad")
    else()
        set(SENTRY_BACKEND "inproc")
    endif()
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(VCPKG_CXX_FLAGS "/D_CRT_DECLARE_NONSTDC_NAMES ${VCPKG_CXX_FLAGS}")
    set(VCPKG_C_FLAGS "/D_CRT_DECLARE_NONSTDC_NAMES ${VCPKG_C_FLAGS}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSENTRY_BUILD_TESTS=OFF
        -DSENTRY_BUILD_EXAMPLES=OFF
        -DSENTRY_BACKEND=${SENTRY_BACKEND}
        -DCRASHPAD_ZLIB_SYSTEM=ON
    MAYBE_UNUSED_VARIABLES
        CRASHPAD_ZLIB_SYSTEM
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(PACKAGE_NAME sentry CONFIG_PATH lib/cmake/sentry)

if (SENTRY_BACKEND STREQUAL "crashpad")
    vcpkg_copy_tools(
        TOOL_NAMES crashpad_handler
        AUTO_CLEAN
    )
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(
    INSTALL "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
