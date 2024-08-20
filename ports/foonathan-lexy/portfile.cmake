vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO foonathan/lexy
    REF "v${VERSION}"
    SHA512 ca263ecb9e3faf8d7a8fd48451f462bcac2c1d34e13d37d99a69135112c6db5b4bc9a9c1b4dd8371ab19f72b408de9fa9f0fa6dc7727a26e8d3a5d22f5f65442
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLEXY_BUILD_BENCHMARKS=OFF
        -DLEXY_BUILD_EXAMPLES=OFF
        -DLEXY_BUILD_TESTS=OFF
        -DLEXY_BUILD_DOCS=OFF
        -DLEXY_BUILD_PACKAGE=OFF
        -DLEXY_ENABLE_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME lexy
    CONFIG_PATH lib/cmake/lexy
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
