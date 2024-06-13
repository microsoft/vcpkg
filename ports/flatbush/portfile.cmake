# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chusitoo/flatbush
    REF "v${VERSION}"
    SHA512 6640265e921998d7de1fca8ee628007687081ba6ab1fb0bd5a0951eac0e76e59b89c441a9baf6abd90ec32271b943974bc8becb1ccfb36fe74811025106620de
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/flatbush)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
