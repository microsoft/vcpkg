include(vcpkg_common_functions)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cmocka/cmocka
    REF cmocka-1.1.3
    SHA512 34c04340e6486ae020e54de086214d41ed3b0b1eb503e1a3f6b88efea61d57f6015bdde1c5619a23e66cb3ffaba884d70f9bfdb15f586739a16a4bce71e11cbb
    HEAD_REF master
    PATCHES
        shared-lib.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUNIT_TESTING=OFF
        -DBUILD_STATIC_LIB=${BUILD_STATIC_LIB}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# Install usage
#configure_file(${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME ${PORT})
