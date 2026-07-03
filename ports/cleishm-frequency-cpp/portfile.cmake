vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cleishm/frequency-cpp
    REF "v${VERSION}"
    SHA512 04b8fe41276135e0ce4e716cf0098d5d9186d9d5ed8309c3cf404371df031653c561e0d0c1727941fff7e38b55ba8caf1b3fdbb27279c405b374eebbfccdf700
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
