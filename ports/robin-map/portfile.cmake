vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/robin-map
    REF v1.0.1
    SHA512 5741049287fdb9c3316e1eb84b99343efc7b35f492e1db8166d65c2d16c7905f51b11cf164bedae9e44d4b6000bbea3c49012acf725a977e665a8dc23e89b1fb
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/tsl-robin-map)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
