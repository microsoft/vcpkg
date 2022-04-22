vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ikalnytskyi/termcolor
    REF 67eb0aa55e48ead9fe2aab049f0b1aa7943ba0ea #v2.0.0
    SHA512 c076f0acafa455fb3ed58bca5f0a0989dc3824e9b4f264fc5aa5b599068cc6551ccc2cfe1180a4ff0f8424e6adbfbbfeed50d395ab5f288b8c678cfa42e8fa17
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${port}/ TARGET_PATH share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
