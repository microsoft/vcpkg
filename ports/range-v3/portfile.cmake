vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ericniebler/range-v3
    REF 4989f3e9ff2efee1852942bb9328ef121369ba02 # 0.11.0
    SHA512 da571feff60d20a42e1e0593f132d4ab095f3ffbecaf0c020f295a2ec8b75c6934abb1974679e55ce8b7b16d105e0cbf3929210677c3b1b90cb349e583854fd4
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
