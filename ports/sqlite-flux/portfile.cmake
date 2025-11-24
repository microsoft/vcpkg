vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO a-alomran/sqlite_flux
    REF v1.1.0
    SHA512 77E84E9B3F15A38F27EA6A819D44DC5244E781FDF92222E75409E9C04C63CBFC4E78217F92E1D7FB64E17B3633DCE3A51DC329B313E81ACE1427D3FCF713B7D7
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME sqlite_flux
    CONFIG_PATH lib/cmake/sqlite_flux
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")