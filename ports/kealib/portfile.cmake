vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ubarsc/kealib
    REF "kealib-${VERSION}"
    SHA512 f7b3e602cefab661621bd1b8f18d7c5dd34f4f514a187274160afd37ec45720bf0c7d0b8053ed422ea7ad301b25c418af60dbf54b86c646afdf660d1b5e57bdd
    HEAD_REF master
    PATCHES
        no-kea-config-script.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBKEA_WITH_GDAL=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_GDAL=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libkea PACKAGE_NAME libkea DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Kealib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
