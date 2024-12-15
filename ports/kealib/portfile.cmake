vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ubarsc/kealib
    REF "kealib-${VERSION}"
    SHA512 be69354d23d2233f9a8b8809e07f0601341e89c29d1c6419fdc69bba2d07c90ccf5f74b4a8bf55164d2f2f95ca23f2865b899133a8db10b6054a38fc57de890e
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
