
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Headers
    REF "sdk-${VERSION}"
    SHA512 436c6ce11d918091ce4a5ef2821f51af811c9a289e220b4a2b0bb4417b1f9f3b1f56a6366cfdf56848a9b1fb612ee3ba31d35c3d73d3d24de964ee05f96a7bbc
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
