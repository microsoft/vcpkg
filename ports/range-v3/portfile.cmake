include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ericniebler/range-v3
    REF 8a732ee6736af8af024b5b2032580b85a9be8239
    SHA512 a052d29fd0164d8a0ad2c70da0fe4e771c98bac3fb5ccdde4819f1b9b865504f9e649736a2adf996e62b08f2499feeaedf19dc47a0ff846d3482b79ef2946ead
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
