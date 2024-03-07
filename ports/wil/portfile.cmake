#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/wil
    REF v1.0.240122.1
    SHA512 b6552924aadb036cf28d21a90d1259720b84fb7f34b2af30444257861143ed4f41cd58586a7cc4c6fb364e73264eaf77669ca988a4a9ef2fe29fdae9e992f936
    HEAD_REF master
)

# WIL is header-only, so we don't need to build it in both modes
set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWIL_BUILD_TESTS=OFF
        -DWIL_BUILD_PACKAGING=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/WIL)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Install natvis files
file(INSTALL "${SOURCE_PATH}/natvis/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/natvis")

# Install copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")