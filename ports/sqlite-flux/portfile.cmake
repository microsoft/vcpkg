vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO a-alomran/sqlite_flux
    REF v1.0.0
    SHA512 7c1486e0b89a719230368f9202049a823420b0305999bef0c4b15567b5fe97aec47862fbffd65e8986423d56a9cdf9d10abace4385e08825ad20a324ec729347
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