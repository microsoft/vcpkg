vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stlab/libraries
    REF "v${VERSION}"
    SHA512 72b280f2c52490db0849472400da1e7fd46d56909124a5ea26e6f05d899c8e58c6f59673be8fa5ea2ea5001191188dbcc8aabdba4dd5b2d0072d18fe457a6fb7
    HEAD_REF main
    PATCHES
        cross-build.patch
        devendoring.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/stlab)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
