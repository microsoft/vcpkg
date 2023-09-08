if(VCPKG_CRT_LINKAGE STREQUAL "dynamic" AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message(FATAL_ERROR "unicorn can currently only be built with /MT or /MTd (static CRT linkage)")
endif()

# Note: this is safe because unicorn is a C library and takes steps to avoid memory allocate/free across the DLL boundary.
set(VCPKG_CRT_LINKAGE "static")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO unicorn-engine/unicorn
    REF 6c1cbef6ac505d355033aef1176b684d02e1eb3a # v2.0.0
    SHA512 7d23def10d1a72a9514ef10f2f9b50f29ce24d4994c06ce5980141a2bed8cdd76478d2e7849b7783e574d1fe97945dc7cd0ce1990c4b4b0479a5170eba4169e1
    HEAD_REF master
    PATCHES
        fix-usage.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUNICORN_BUILD_TESTS=OFF
    )

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

if(EXISTS "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")
    vcpkg_cmake_config_fixup(PACKAGE_NAME "unofficial-${PORT}" CONFIG_PATH "share/unofficial-${PORT}")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
