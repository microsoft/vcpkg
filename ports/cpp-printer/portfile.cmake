vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BlueNovaStudio/bluenova-toolkit
    REF v1.0.0
    SHA512 5d4e4031e3218778587c32e589b9d206f614bbf9ed92c038da144d8fc0dfbdf2eb7cfa5974c119bdd1dca5d0f90490d369933ac5eb80276a21718f8907854e57
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME cpp_printer
    CONFIG_PATH lib/cmake/cpp_printer
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/lib"
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE"
)
