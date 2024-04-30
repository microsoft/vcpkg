vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO magiblot/tvision
    REF d1fa783e0fa8685c199563a466cdc221e8d9b85c
    HEAD_REF master
    SHA512 84c7c4f47274fa4976004b2d542e47446f4bb3eca54b4426f19a2de5e381eb78e42d87f12ab00d7d6ceb05d3d32462da2c02dc3e4a7ef06e3f6fcbbe87c30ac1
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DTV_BUILD_EXAMPLES=OFF
        -DTV_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT")
