vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stescobedo92/swagger-cpp
    REF v0.3.0
    SHA512 19773bc0d903d3a4a50477fc33cfebb490e86f0761fedc619da26d5ae4dfcd084f95c1616573b347d29f1a3e1062c808a11811dcd5b9a61ef13b7aaf0eb3856e
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
