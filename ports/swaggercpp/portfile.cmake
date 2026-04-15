vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stescobedo92/swagger-cpp
    REF "v0.2.1"
    SHA512 8258929fd1d281b4d44395794fb0db4735e59fa50af085329be96642ac15d76231769363e49ae974001fa3843c6152c144f2598537eeeaa50252bd496ab3c01d
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSWAGGERCPP_BUILD_TESTS=OFF
        -DSWAGGERCPP_BUILD_BENCHMARKS=OFF
        -DSWAGGERCPP_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME swaggercpp CONFIG_PATH lib/cmake/swaggercpp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
