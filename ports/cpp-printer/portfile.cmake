vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BlueNovaStudio/cpp-printer
    REF v1.0.3
    SHA512 9f7b853b3dd9776d7e3e19eaa1dff56daa3cb6ba1240376f1ea73f49258cf59ef9b298b5465dfe7d5271366a9c0a0fb7196d046dda572d88303348fe8f98b72f
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
