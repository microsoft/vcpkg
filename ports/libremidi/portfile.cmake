vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jcelerier/libremidi
    REF "v${VERSION}"

    SHA512 8799f1edc1d700c96d4219398278dcf6c5e920c8ad08a39a70a64f4d21bc41863642cf9981b3c546e488463b3311f556f81df0c7eafeee9c405fcb83fa6e638c 
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libremidi PACKAGE_NAME libremidi)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

