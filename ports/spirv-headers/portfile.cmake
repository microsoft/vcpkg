
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Headers
    REF "vulkan-sdk-${VERSION}"
    SHA512 d3328cd4ddf87d075afacfb7ada01dbd16a3ff39b831e9ebe4ce3c32af0ff0c8822811b0e0d273a54b4acaba29b63b099efcf0150424bd9074d24d04a9974d89
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
