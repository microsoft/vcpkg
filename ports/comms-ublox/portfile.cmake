#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commschamp/cc.ublox.generated
    REF v0.20
    SHA512 ceb0a8c524ce0857e77eaf0971c062d86d3c5588507755095e8f8080ab665d88af9c69dd136a9c5a38a895496f03e2764d1e892ca16318a5494c02178f5d389a
    HEAD_REF master
    PATCHES
        fix-comms.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
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
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
