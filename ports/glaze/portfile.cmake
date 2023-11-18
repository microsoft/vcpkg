if(VCPKG_TARGET_IS_LINUX)
    message("Warning: `glaze` requires Clang or GCC 10+ on Linux")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stephenberry/glaze
    REF "v${VERSION}"
    SHA512 8c39fd370d46251dc528d09145efb7cb0645e02d3590fca1734a2e66ab46ff762128e80bec83abea98827786c475d2d647b5f0a7405f9e0d78f7cf0348bca515 
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dglaze_DEVELOPER_MODE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
