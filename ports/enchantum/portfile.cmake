vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ZXShady/enchantum
    REF ${VERSION}
    SHA512 97e9cdfc238293b2f9e694df1d29db0a4f1bad1f96e4c861e6ea8f2d1805f0a95b69c82c5ad9720cc1b2868572e8299269f85c9730aa34b6e78bd70cf1367843
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "share/enchantum/cmake")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
