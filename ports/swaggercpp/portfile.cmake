vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stescobedo92/swagger-cpp
    REF v0.3.0
    SHA512 4b35a8db282613e6fc1a873f47ab2edfe21f7c8aefd1f0cdbdb7be92207930d7dcd5788134d87298bd89e421989a330ac9a1db6ef6d33a42317e2953336f30a9
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
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
