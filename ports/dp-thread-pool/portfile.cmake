set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DeveloperPaul123/thread-pool
    REF ${VERSION}
    SHA512 a333c02ca917ce8d3f41e5ec2b74259e9fd503a909a19c742b628b75df94502f32ba364bb578923f2e3abecf2631c814ae39c252660fea90aaa933b39bf574b9
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTP_BUILD_TESTS=OFF
        -DTP_BUILD_EXAMPLES=OFF
        -DTP_BUILD_BENCHMARKS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME thread-pool
    CONFIG_PATH lib/cmake/thread-pool-${VERSION}
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
