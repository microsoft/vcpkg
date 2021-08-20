if(NOT VCPKG_TARGET_IS_OSX)
    vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "UWP")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/getsentry/sentry-native/releases/download/0.4.12/sentry-native.zip"
    FILENAME "sentry-native-0.4.12.zip"
    SHA512 15da4407ed5e2c8d5e56e497ccc6006b29235aef6b3a81e034c93443e20a7cfdf95d55e31b88e552c55e824eb15d6f7fafe988c453a5a6f36fe45136d7268b19
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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSENTRY_BUILD_TESTS=OFF
        -DSENTRY_BUILD_EXAMPLES=OFF
        -DSENTRY_BACKEND=${SENTRY_BACKEND}
        -DCRASHPAD_ZLIB_SYSTEM=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sentry TARGET_PATH share/sentry)

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
    INSTALL ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright
)
