vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "UWP")

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/getsentry/sentry-native/releases/download/0.4.7/sentry-native.zip"
    FILENAME "sentry-native-0.4.7.zip"
    SHA512 ad007bdee5fd6ff5afa1a2ee6a44de0cd1f7c05ab51a037b0a974ba99770d7a5eac6bd62da39ad11645dbc64a016925bb96be7a1ac4c1fcb473046a10393a508
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
    PATCHES
        fix-warningC5105.patch
        fix-config-cmake.patch
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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSENTRY_BUILD_TESTS=OFF
        -DSENTRY_BUILD_EXAMPLES=OFF
        -DSENTRY_BACKEND=${SENTRY_BACKEND}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sentry TARGET_PATH share/sentry)

if (WIN32 AND SENTRY_BACKEND STREQUAL "crashpad")
    vcpkg_copy_tools(
        TOOL_NAMES crashpad_handler
        AUTO_CLEAN
    )
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(
    INSTALL ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright
)
