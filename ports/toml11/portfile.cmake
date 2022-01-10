vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ToruNiina/toml11
    REF v3.7.0
    SHA512 093833ea4354ab91f54c0a346e51d38e297b8c347241f679c023e65fe580edca7852d934a0a0d371524426f61e58ee3a9638061b1230cd72be7ff55fcf12370c
    HEAD_REF master
)

vcpkg_cmake_configure(
        SOURCE_PATH ${SOURCE_PATH}
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