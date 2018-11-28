include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ericniebler/range-v3
    REF 00d4676502aa257a3ce934b50555211b4791ae05
    SHA512 a0067e1b0d1d2261c2f868ebc57278b74a081ccc00dcd65648b5c362317c6cd3321fb3b9936733d839cd9d48cf801d1f23710bce9e33edd9dfa8f32556d90526
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
