# Header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO efficient/libcuckoo
    REF f3138045810b2c2e9b59dbede296b4a5194af4f9
    SHA512 b1682b7175b2a7fd22c34cbaf9770f2f1bfb3f0d1be046338a8a489c302f0434ca1cbf2ffe5845e09aba132b0be6a1d6472b66b4518bb172b82af93a9d27cd21
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_STRESS_TESTS=OFF
        -DBUILD_UNIT_TESTS=OFF
        -DBUILD_UNIVERSAL_BENCHMARK=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
#vcpkg_test_cmake(PACKAGE_NAME ${PORT})
