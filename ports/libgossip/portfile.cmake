vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO caomengxuan666/libgossip
    REF "v${VERSION}"
    SHA512 a1b9d0e1f0b83a321748c3cd18a9e8e314f916b58ba54b88d3715a95aea88ac6dbf62b5923c26ccc76af9c5715b2f6ae8bf10e3e4f01fe8dbaed2ec019460f9c
    HEAD_REF main
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DBUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libgossip)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
