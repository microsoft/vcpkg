vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/MoltenVK
    REF "v${VERSION}"
    SHA512 0
    HEAD_REF main
)

vcpkg_configure_make(
  SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_install_make()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
