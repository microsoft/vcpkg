vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/hopscotch-map
    REF "v${VERSION}"
    SHA512 22a2ea5089ef6ef7afb872f6785a1f1d063660a7cb22ccfd4ccbecf95fd0a71ffc72fbb814ac51be8ed7445e75d0d8b79e619d08d7ddf063968fe6e7bf995932
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright
)
