vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO depz-ai/depz-sensor-sdk
    REF "v${VERSION}"
    SHA512 a55df8ece752f5288df0fc1c5db09b5caccf4a300e37adbe29a40434252fec7cfea901eb78236f878e838e10b30c1cf766ca1187c0afea574bcb356c998b06d8
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

# The depz-sensor-sdk-c package ships its own LICENSE file (MIT, with the
# BSD-3-Clause note for the shared VL53L8 advanced-DCI codecs used here).
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/packages/depz-sensor-sdk-c/LICENSE")
