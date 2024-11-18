vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vtraag/libleidenalg
    REF "${VERSION}"
    SHA512 254b5454086683af3655c7e0e18cca8c24ceb899e0614940ab84a50fb2eea57d1b6409eb19a92976758b4d3066c86b643512356eb38d33311c80ff701381c433
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
