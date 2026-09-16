vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emoon/minifb
    REF "v${VERSION}"
    SHA512 b96b6d15ab2157d3d00dbe90cbcfd2ca606c91402dd78519ea666c4916b1337182a25d3c6bbf5c7c0658589b6288661726b02f36d27ce8d3b5293729b7701154
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMINIFB_BUILD_EXAMPLES=FALSE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
