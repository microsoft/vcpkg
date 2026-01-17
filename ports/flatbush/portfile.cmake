# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chusitoo/flatbush
    REF "v${VERSION}"
    SHA512 243eb75fe234731f65aaee491124b82e3dd096f6dd707c666ad4d769fe3e7464ceff240ce33ec88d20062247f12fb0c001a44fee7aa511b6e6b561fc107686c1
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
