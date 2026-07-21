vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cleishm/frequency-cpp
    REF "v${VERSION}"
    SHA512 97b3dd1a84e343530c1dc717323f206ef7b4b0be21396f85239c0e77aa4d2adc4e9774e8525c91ffc60d20d2e0b57667de698caed9c8518a897e2e7ab9ab512c
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
