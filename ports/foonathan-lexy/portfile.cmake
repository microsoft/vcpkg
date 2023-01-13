vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO foonathan/lexy
    REF "v${VERSION}"
    SHA512 9818882bd83e19a0087ced3c209ae13645df675f1c5cb8f67f06d0993de9d19dadbc7684147abe9236fde1f688e0e539dc519d4198a3e3b5d247137a2675bd77
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
