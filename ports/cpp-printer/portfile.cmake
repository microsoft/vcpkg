vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BlueNovaStudio/cpp-printer
    REF v1.0.2
    SHA512 b1818d1fe068a452cbdfd6b832a2fdd2e8b13f1029f9a49428de8c1efc046cb622c934a35a9cfc04668f0e7188c0d7158533352c4ac71e2557b3983e88ee36eb
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
