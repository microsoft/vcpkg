vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO themoos/core-moos
    REF "v${VERSION}"
    SHA512 8a82074bd219bbedbe56c2187afe74a55a252b0654a675c64d1f75e62353b0874e7b405d9f677fadb297e955d11aea50a07e8f5f3546be3c4ddab76fe356a51e
    HEAD_REF master
    PATCHES
        cmake_fix.patch
        include_functional.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/MOOS)

# Stage tools
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Core/GPLCore.txt")
