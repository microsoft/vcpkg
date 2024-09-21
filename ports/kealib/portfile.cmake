vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ubarsc/kealib
    REF "kealib-${VERSION}"
    SHA512 ccaaf9d5031eac32bf1a0e6b9e9efb4f5245fc730d33bd9931efb1a6f529990c6da8ddd400ec0d58ee527675057b74c81393d263c9b182ac5f9a8796273b001f
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
