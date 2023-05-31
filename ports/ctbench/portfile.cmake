vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jpenuchot/ctbench
    REF v1.3.2
    SHA512 f04f03e556beaef6b8a62d54ff4b0ace14cb582ef5f7c584798a073f2794bd6be8e1186ab41a0b23d104e0a06ddf25139ef67c515bd9891928af026d773a9632
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DCTBENCH_ENABLE_TESTS=OFF
        -DCTBENCH_ENABLE_DOCS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ctbench
    TOOLS_PATH bin/)
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/ctbench" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
