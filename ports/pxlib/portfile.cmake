string(REPLACE "." "-" VERSION "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO steinm/pxlib
    REF R-${VERSION}
    SHA512 91a27d9935de288b54d6ecf7a9f863b93fa30c011315fedd8c1c71232714d64a463bbb232112a0df2252263c1ac2364d1be3368f63b133398f0fb065c300ae52
    HEAD_REF master
    PATCHES
        add_cmake_config.patch
        add_extern_c.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_GSF=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-pxlib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
