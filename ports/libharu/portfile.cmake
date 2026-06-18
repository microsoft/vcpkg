vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libharu/libharu
    REF "v${VERSION}"
    SHA512 c16b1770cd06ffb3d02649de2f4a9e84ca2c42d82183194e01802bf8c6745609a176185d00e37bb06cae9b3245c154cf7e267e47bd71b3b9aa572c28214fec69
    HEAD_REF master
    PATCHES
        export-targets.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-libharu)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/libharu/bindings"
    "${CURRENT_PACKAGES_DIR}/share/libharu/README.md"
    "${CURRENT_PACKAGES_DIR}/share/libharu/CHANGES"
    "${CURRENT_PACKAGES_DIR}/share/libharu/INSTALL"
)

vcpkg_copy_pdbs()
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
