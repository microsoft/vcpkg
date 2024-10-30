set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nemtrif/utfcpp
    REF "v${VERSION}"
    SHA512 49ca33bfb2ee44515f555184b51191f7b706a228fb84ddc62e1e6b59c7d69a5ff836f38694daad0012a0f651b6199451974fe44ebe80081df00cf8c2759e3249
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME utf8cpp CONFIG_PATH share/utf8cpp/cmake)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
