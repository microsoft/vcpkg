vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/getsentry/sentry-native/releases/download/0.4.14/sentry-native.zip"
    FILENAME "sentry-native-0.4.14.zip"
    SHA512 92b970b9c809f39ee7fe58eecc3c7fc4720791c529c284e3ee36756e1e7ebd1b4272d295bec85db2d9e3f11af493c9907994fc3f81ecb376afbec92a704230dc
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
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/sentry)

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
