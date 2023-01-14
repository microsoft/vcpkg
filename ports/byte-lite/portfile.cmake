vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/byte-lite
    REF v0.3.0
    SHA512 a49c7cf820db2bcf63f231324bca72642161fcaa4ecd9e4b18aa752902f393a3983014feae824fa4f5dea0e7182eadded1a9a83c469fa4039d4d17b3c814b2ef
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBYTE_LITE_OPT_BUILD_TESTS=OFF
        -DBYTE_LITE_OPT_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
