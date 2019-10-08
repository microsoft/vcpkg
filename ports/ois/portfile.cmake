
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wgois/OIS
    REF v1.5
    SHA512 5ab1dda7c25c1959ccbbb758ea3fda36bd62ad65f46e2c6b418317a5eb39e0bace52a44ae079dfb69fc58c90df54f8e50d589daae1100ec615325363c9d77513
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

# Include files should not be duplicated into the /debug/include directory
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME ${PORT})