vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ph3at/libenvpp
    REF v${VERSION}
    SHA512 1c5d0575d9f1668c68d23aa4163eba18a90173ac7601d8b8f142d9826e3971ad9d0a1d880d6d3f8a80ed964b4fca2e28590d130fdce542d85e04413687b3b0ae
    HEAD_REF main
    PATCHES
        fix-dependencies.patch
        fix-install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBENVPP_EXAMPLES=OFF
        -DLIBENVPP_TESTS=OFF
        -DLIBENVPP_CHECKS=OFF
        -DLIBENVPP_INSTALL=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
