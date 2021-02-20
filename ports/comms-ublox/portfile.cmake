#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commschamp/cc.ublox.generated
    REF v0.19.1
    SHA512 4f599bc052ea4f4dd4158c7e2d2bd4020393802d8f2bcd97637a618190789cd5797e3e3b56da868949a261d1d4a34b4bf613a97ad28e0da87f82b3f5452498e7
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
