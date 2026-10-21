vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO a-alomran/sqlite_flux
    REF v1.1.1
    SHA512 abd71e9b99b27b4edebe8f49e978212498b0914170b9fe41b4111121eb2d732b9b2939add9f6732d474008628eb3e05e0945f7687504da837d497a93d96d3376
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