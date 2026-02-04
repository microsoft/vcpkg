
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Headers
    REF "vulkan-sdk-${VERSION}"
    SHA512 b4f975d3051eda41ef5c3a6efc832607a165adfd6f43d7af171d2c0446b227bdcb5de0017a081fa9e7a3d2710ba8583fadbc06c0a364043b2778b02818d01040
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
