include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ericniebler/range-v3
    REF 0.5.0
    SHA512 076be03b0f4113acb5fb4db83ed5e755bed60ff8df9a7b982b144949cce40f0bb0579ecca38c1f33643b63037b8d311afa6d613b50811e1191b63e2c42a0d4bf
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

file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/range-v3)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/range-v3/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/range-v3/copyright)
