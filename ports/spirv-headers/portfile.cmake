
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Headers
    REF "vulkan-sdk-${VERSION}"
    SHA512 c9d448a74006a5fdf59993e6d6a9c617bab4c5df23c333b7ada386e4ca25caaae28fc83f71963ce8468646113d83d6e7b17c26c46c3b6485c8df91f142755977
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
