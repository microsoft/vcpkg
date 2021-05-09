#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/wil
    REF 86353933d5fba0caf61503c8b09e10e182dccdfb
    SHA512 07694a3754c179aa629b8e3e8fc2a5554779601925131bffef311dee937b03db0d1be891eaee364b7a265b7268f39ad356d8302c02b05acf4fa8c7b2d4d51629
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWIL_BUILD_TESTS=OFF
        -DWIL_BUILD_PACKAGING=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/WIL)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)