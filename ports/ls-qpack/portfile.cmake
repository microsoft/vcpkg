if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO litespeedtech/ls-qpack
    REF "v${VERSION}"
    SHA512 641cd23496e92c45505772303287ae840652545b67de7e0751662e012b6ca7017ce951d699bcf451256cb8c5d0952dc118684b99cdf9ed3fe5726e08e2ed1dc6
    HEAD_REF master
    PATCHES
        fix-version.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/deps")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLSQPACK_TESTS=OFF
        -DLSQPACK_BIN=OFF
        -DLSQPACK_XXH=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ls-qpack)

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
