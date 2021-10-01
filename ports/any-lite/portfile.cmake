vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/any-lite
    REF d45a83b8e49d09ff5e5b66c10a56c997946436d9  #v0.4.0
    SHA512 b73fe2d1e6de24e143337ef72f71949bf2ae4157a58a5c7e45dd0e9412dd798da6ef929fa09d104305483e769a603b37babd7ba65ab854a33483ab3ec8a921ec
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DANY_LITE_OPT_BUILD_TESTS=OFF
        -DANY_LITE_OPT_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
