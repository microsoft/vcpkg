vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cleishm/frequency-cpp
    REF "v${VERSION}"
    SHA512 80608489ab13ae544aa6d458610a9e5a3432d5997ddc5a2d345ecf1cce57f29cd6ea77b28592632b81667019fd5589c71c8fb0f02f67a9319cfeac9ad99b2686
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFREQUENCY_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME frequency CONFIG_PATH lib/cmake/frequency)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
