include(vcpkg_common_functions)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cmocka/cmocka
    REF c4cdb7435b1666bf76e7d336662303972622fc01
    SHA512 8729d12c4457d0f55dd71b6094613015892be26115c11e820f32e1dad62e0d6614e7d995b3255fe24d34d5ade402e5d2eb466c1ae5292d235f953d19716d28c9
    HEAD_REF master
    PATCHES
        shared-lib.patch
        static-lib.patch
        fix-uwp.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIB)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUNIT_TESTING=OFF
        -DWITH_EXAMPLES=OFF
        -DBUILD_STATIC_LIB=${BUILD_STATIC_LIB}
        -DWITH_STATIC_LIB=${BUILD_STATIC_LIB}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# Install usage
configure_file(${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)

# CMake integration test
#vcpkg_test_cmake(PACKAGE_NAME ${PORT})
