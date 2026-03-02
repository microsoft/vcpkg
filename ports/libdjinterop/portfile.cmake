vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xsco/libdjinterop
    REF "${VERSION}"
    SHA512 45969510c2a2c863bd9627ddc73f404c84d12cc0eea922c23a04dc3486420188936ef556e6a5372e3cc390b3b12d748d64d0cae82a845d6306a4da18227bb435
    HEAD_REF master
    PATCHES
        devendor_libs.diff
)

file(REMOVE_RECURSE "${SOURCE_PATH}/ext")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Boost=ON
    )
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME djinterop CONFIG_PATH lib/cmake/DjInterop)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
