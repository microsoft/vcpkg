vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ericniebler/range-v3
    REF 2e0591c57fce2aca6073ad6e4fdc50d841827864
    SHA512 381d3f7cf7832f51854e5f067a3e6a7df143921067540482d45ce115c792634113f5dfb3dcfb7a69bb5c879d1591c50610177bfe795cd97993130adedcb118d3
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DRANGE_V3_TESTS=OFF
        -DRANGE_V3_EXAMPLES=OFF
        -DRANGE_V3_PERF=OFF
        -DRANGE_V3_HEADER_CHECKS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/range-v3)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
