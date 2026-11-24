set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nemtrif/utfcpp
    REF "v${VERSION}"
    SHA512 3abff4aef40a418f546e4033c71be6d77071b2603a5e518cae07d8120ecaebee34f6e3aef7b75928846ac5cd0cd103398e84aa38a126df50f8b0abd544173d43
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME utf8cpp CONFIG_PATH share/utf8cpp/cmake)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
