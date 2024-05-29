vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ToruNiina/toml11
    REF "v${VERSION}"
    SHA512 74a70abe413e21b94284242c281645c49f08b930c62f5479e6698cee45a99b56511d0a8888f1f6f2af3fc245bb0dfd5048a0b810b474ca1066211e25a1ce33bb
    HEAD_REF master
)

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            -Dtoml11_BUILD_TEST=OFF
            -DCMAKE_CXX_STANDARD=11
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