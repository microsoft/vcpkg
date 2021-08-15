#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commschamp/cc.ublox.generated
    REF v0.20.2
    SHA512 5672d964ea3e505837e44a5fd928069a219a5731764cb54bfe8609e39c6c6dd0059660bcde317c6c60cd1bd8d1f7942d2faa022095bf651817568291bc6a7569
    HEAD_REF master
    PATCHES
        fix-comms.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DOPT_BUILD_TEST=OFF
        -DOPT_BUILD_PLUGIN=OFF
        -DOPT_NO_COMMS=ON
        -DOPT_EXTERNALS_UPDATE_DISCONNECTED=ON
)
vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/ublox/cmake TARGET_PATH share/ublox)
# currently this is only a header only library. after moving lib/ublox to share this lib path will be empty
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
