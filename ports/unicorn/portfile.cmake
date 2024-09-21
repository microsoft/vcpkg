if(VCPKG_CRT_LINKAGE STREQUAL "dynamic" AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message(FATAL_ERROR "unicorn can currently only be built with /MT or /MTd (static CRT linkage)")
endif()

# Note: this is safe because unicorn is a C library and takes steps to avoid memory allocate/free across the DLL boundary.
set(VCPKG_CRT_LINKAGE "static")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO unicorn-engine/unicorn
    REF "${VERSION}.post1"
    SHA512 8694d6bc92e3424a8ad050316413d53e56e0f55e7cad7517fb3e98e670a0f1768b060ead8f195da13607cec89a964364f05a8b9d0dc074f4ac5e51026f8343ad
    HEAD_REF master
    PATCHES
        fix-build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUNICORN_BUILD_TESTS=OFF
    )

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
