vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO offscale/c89stringutils
    REF "${VERSION}"
    SHA512 82edb341d5566c42eaffcd5c87d4fbd82a4e47b9c31a8533b08d28b9e1311ced281b59b3b6103e274355a82117095fcff1cb5f9c29eecc9563dc3cd962a37773
    HEAD_REF master
    PATCHES
        no_flags.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-APACHE" "${SOURCE_PATH}/LICENSE-MIT")
