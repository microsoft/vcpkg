include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO onqtam/doctest
    REF 2.3.4
    SHA512 ca97da8e22684f2d901d0a9dc9c1d0c7126a850f75fe20c37a4d8bbc6f7eafc961313a6c58ca712f00465fff107e1b6b6d9557d2b04edb3029b0035bcfa6db20
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DDOCTEST_WITH_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/doctest)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/doctest/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME ${PORT})
