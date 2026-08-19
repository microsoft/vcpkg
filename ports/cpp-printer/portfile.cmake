vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BlueNovaStudio/cpp-printer
    REF v1.0.1
    SHA512 fea94740e9283cb1a839605f317ac7dcc8d6530e4ce74b7b5c61d6eb78cfd6c50da63f3622e8942eeb9ecd7800bea9b348fed3bfd492abcc0902e356217ab088
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
