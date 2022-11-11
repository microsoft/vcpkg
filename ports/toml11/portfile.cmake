vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ToruNiina/toml11
    REF v3.7.1
    SHA512 a4710972ab9b1ff836b2191243d628e0c4672fbfe95ede50c49796aaa75bb05d3ac71164102651d5c7342a4ac88781dfe417957b8b8ce373989f627231966550
    HEAD_REF master
)

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            -Dtoml11_BUILD_TEST=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/toml11)

vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/share/toml11/toml11Config.cmake"
        "\${PACKAGE_PREFIX_DIR}/lib/cmake/toml11/toml11Targets.cmake"
        "\${PACKAGE_PREFIX_DIR}/share/toml11/toml11Targets.cmake"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)