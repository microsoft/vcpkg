vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BlueNovaStudio/cpp-printer
    REF v1.0.4
    SHA512 27c7df08ed2cced8e28f17e858be3a019a9b04dacec2218b33b1a63ffcea69843bf52a1bd2cc96f2eb1e37450d920a2c04f194a3849398687becb961229cffc4
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCPP_PRINTER_BUILD_CLI=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME cpp_printer
    CONFIG_PATH lib/cmake/cpp_printer
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/lib"
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE"
)
