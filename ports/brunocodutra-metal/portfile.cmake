# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brunocodutra/metal
    REF 43256d2c7f5715d9dc029037bcd8512624ec7865 # v2.1.1
    SHA512 fc69e60b9c21d0215ca2c9ec27ab65d59115397e1d27c90fcdc35ccf8675546b1fbc3be0e6b8f69cd8eb848bac348ca0fe116f50a36ce8d1cbff0d646c4f05cb
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(
    CONFIG_PATH lib/cmake/Metal
    TARGET_PATH share/metal
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME ${PORT})
