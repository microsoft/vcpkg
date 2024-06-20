vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rvarago/absent
    REF 0.3.1
    SHA512 c7b7d29422ef8afc48e3093496e1dd055cfe9969ae037c2b06ea70fe4283e7a7e9129171efaa257e909c535e24df5861b992b24b00ec03f965730e6a22e13015
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/${PORT}
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

file(INSTALL
    "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

file(INSTALL
    "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright
)

