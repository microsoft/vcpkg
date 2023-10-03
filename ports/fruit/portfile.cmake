
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/fruit
    REF "v${VERSION}"
    SHA512 82e86b939ce7d1c0f092255211cd0825e7cf96e56b4af44dcbb67c863c41cb398afbbf9098a934b7eea848acc0b48d3dee3a67cf907f9b9ef2a0d59d92507f30
    HEAD_REF master
)

# TODO: Make boost an optional dependency?
vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DFRUIT_USES_BOOST=False
        -DFRUIT_TESTS_USE_PRECOMPILED_HEADERS=OFF
)

vcpkg_cmake_install()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
