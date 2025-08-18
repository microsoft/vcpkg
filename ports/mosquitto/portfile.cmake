vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eclipse/mosquitto
    HEAD_REF master
    REF "v${VERSION}"
    SHA512 ca8bdcb10fea751e655e2de393479b2f863287b396b13e441de46c32918229c1f80a386fdd6d0daf3b0161f640702b6d8a87f2278c9baf2150e2c533cb59e57a
    PATCHES
        linkage-and-export.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/deps")
file(COPY "${CURRENT_PORT_DIR}/unofficial-mosquitto-config.cmake" DESTINATION "${SOURCE_PATH}/lib")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" STATIC_LINKAGE)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWITH_STATIC_LIBRARIES=${STATIC_LINKAGE}
        -DWITH_SRV=OFF
        -DWITH_TLS=ON
        -DWITH_TLS_PSK=ON
        -DWITH_THREADING=ON
        -DDOCUMENTATION=OFF
        -DWITH_PLUGINS=OFF
        -DWITH_CJSON=OFF
        -DWITH_CLIENTS=OFF
        -DWITH_APPS=OFF
        -DWITH_BROKER=OFF
        -DWITH_BUNDLED_DEPS=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-mosquitto)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/mosquitto-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
