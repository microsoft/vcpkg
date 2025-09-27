set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nemtrif/utfcpp
    REF "v${VERSION}"
    SHA512 9692c4a581944c6cc41ae050243d81604ada1c9f7fe7df7f24ea3b98879c5ed73ddc3a4ff89258247fd19f91403cbddb2a1f9c153511b6065d856bbcba89bde8
    HEAD_REF master
    PATCHES
        add-cplusplus-flag.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME utf8cpp CONFIG_PATH share/utf8cpp/cmake)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
