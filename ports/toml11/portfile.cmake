vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ToruNiina/toml11
    REF v3.5.0
    SHA512 19c6ee42aa1e186689062e5d2be05f375c8ae4be40be4b6a8e803a642f37214270d5600ccec3d06b4e69aec6896d823e3a8faea29a41643279922d1fe9fae70a
    HEAD_REF master
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA # Disable this option if project cannot be built with Ninja
        OPTIONS
            -Dtoml11_BUILD_TEST=OFF
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/toml11 TARGET_PATH share/toml11)

vcpkg_replace_string(
        ${CURRENT_PACKAGES_DIR}/share/toml11/toml11Config.cmake
        "\${PACKAGE_PREFIX_DIR}/lib/cmake/toml11/toml11Targets.cmake"
        "\${PACKAGE_PREFIX_DIR}/share/toml11/toml11Targets.cmake"
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)