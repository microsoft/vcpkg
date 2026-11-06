vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Cadons/ctus
    REF ${VERSION}
    SHA512 077c9070db249a2211bf725b81fb4d53f41bb25b4d4935167020313289993c3b981df3de30bcbc9bd4c811bd6af11f947adb0bbfb6507c99e86c65c9a7dbe17d
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME ctus CONFIG_PATH lib/cmake/ctus)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
