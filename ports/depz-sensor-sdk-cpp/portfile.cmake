vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO depz-ai/depz-sensor-sdk
    REF "v${VERSION}"
    SHA512 33042a6ee43b7ad91e28ebcb6193def164a3602d19713f80bf9392fe0f9dba96824cee3e95d1f8c74449a7564034d76ae7e5ddaea2045d06311b6588bb2f7c88
    HEAD_REF main
)

# The C++ SDK lives in a subdirectory of the monorepo.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/packages/depz-sensor-sdk-cpp"
    OPTIONS
        -DDEPZ_SENSOR_SDK_CPP_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME depz-sensor-sdk-cpp
    CONFIG_PATH lib/cmake/depz-sensor-sdk-cpp
)

# Static library: no headers belong in the debug tree.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/packages/depz-sensor-sdk-cpp/LICENSE")
