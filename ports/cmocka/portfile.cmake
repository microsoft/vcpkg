include(vcpkg_common_functions)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cmocka/cmocka
    REF cmocka-1.1.5
    SHA512 4e305e500f448676be5503972c49089c51f38b47d8129add2205608ed73f9de8b911aee83c00da4ef52c0179a5b5ba0e3386f3bca839f18e7ab21787184d9990
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

file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# Install usage
configure_file(${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)

# CMake integration test
#vcpkg_test_cmake(PACKAGE_NAME ${PORT})
