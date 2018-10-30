include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ericniebler/range-v3
    REF 7f2eb04e62e44074ddae64ba3715bc800f7c317b
    SHA512 118e4bdba0ade864967ca56f82c7b26cfb6767c483844ffb9995b5e860533d365f91f6795b227e78a228569a2280e995c6d23feac5c493ad7718b6ae00d40eed
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DRANGE_V3_TESTS=ON
        -DRANGE_V3_EXAMPLES=ON
        -DRANGE_V3_PERF=ON
        -DRANGE_V3_HEADER_CHECKS=ON
        -DRANGES_CXX_STD=17
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/range-v3)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/range-v3)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/range-v3/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/range-v3/copyright)