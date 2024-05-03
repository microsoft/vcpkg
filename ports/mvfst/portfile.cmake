vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/mvfst
    REF "v${VERSION}"
    SHA512 8bbaee5a91a041fa6406f1c5bb3eceb6e2ef79ef82416ed10f29063650b28bdaf035e7d3caa987ecbd567d7502a1e9ce5ff9ca7ebe1eca03d37042a6353744eb
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/mvfst)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
