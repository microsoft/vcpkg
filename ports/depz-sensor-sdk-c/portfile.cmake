vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO depz-ai/depz-sensor-sdk
    REF "v${VERSION}"
    SHA512 33042a6ee43b7ad91e28ebcb6193def164a3602d19713f80bf9392fe0f9dba96824cee3e95d1f8c74449a7564034d76ae7e5ddaea2045d06311b6588bb2f7c88
    HEAD_REF main
)

# The C SDK lives in a subdirectory of the monorepo.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/packages/depz-sensor-sdk-c"
    OPTIONS
        -DDEPZ_SENSOR_SDK_C_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME depz-sensor-sdk-c
    CONFIG_PATH lib/cmake/depz-sensor-sdk-c
)

# Static library: no headers belong in the debug tree.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# The depz-sensor-sdk-c subdirectory ships no standalone LICENSE file; the
# repository's MIT license text lives in the sibling depz-sensor-sdk-cpp
# subdirectory and applies to the whole monorepo (it also carries the
# BSD-3-Clause note for the shared VL53L8 advanced-DCI codecs used here).
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/packages/depz-sensor-sdk-cpp/LICENSE")
