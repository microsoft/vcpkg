vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CrowCpp/crow
    REF "v${VERSION}"
    SHA512 32c956a36652ac14a9ffd41333b9e80031f86b99b09f54affb9cb0196c4672c5877daebf6327a359c735f5246dd4119cf17ac5d68271953bfa389d660f745e42
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCROW_BUILD_EXAMPLES=OFF
        -DCROW_BUILD_TESTS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Crow)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
