vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stescobedo92/az-dashboard
    REF v0.1.0
    SHA512 bee34cfb8db6591f8eca7bd442dba8db9f04c9bec222cf54590c8d9aff4001e047d0e5dbf6b96527ec8a28be0565ab31605b54bb80f9f84b7030c4be9ff9c304
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DAZ_DASHBOARD_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME az-dashboard CONFIG_PATH lib/cmake/az-dashboard)
vcpkg_copy_tools(TOOL_NAMES azdash AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
