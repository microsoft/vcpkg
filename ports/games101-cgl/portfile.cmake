vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO endingly/games101-cgl
    REF v${VERSION}
    SHA512  609bc549a5bb20254fa8ae8a765b688352d017bf4f1fa278385b534da3c75eb81fc893dd1736db7efd0ab13c62de3597ccb678a3c2a6f31c0ee6549f6d5c9f3d
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")