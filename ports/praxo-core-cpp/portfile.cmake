vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO axisvela/praxo-core
    REF cbeade3c91d9035174350ec95560efffb661708c
    SHA512 95e2b45ea999ff10302b04cc471291c890fb865984d62bffd17896ba6df094028757bf119aabfd158b9816c131cbcd120a0ef9c70a776802d77a655667456141
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/language/cpp"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME praxo-cpp
    CONFIG_PATH lib/cmake/praxo-cpp
)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
