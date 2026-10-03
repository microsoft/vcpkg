vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Amsozzer1/PlusWeb
    REF "v${VERSION}"
    SHA512 ae55cb520e26f13f47ad6c33b08d380e5e8050a5fd4586ca30b714012467e654f79a1ada2040e5fcbae88e2c202063c9bfb02a9e1a109349a8a2b592b7be3571
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPLUSWEB_BUILD_TESTS=OFF
        -DPLUSWEB_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME PlusWeb CONFIG_PATH lib/cmake/PlusWeb)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
