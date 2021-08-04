#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commschamp/cc.ublox.generated
    REF v0.20.1
    SHA512 a03a5e63a1430d91d0f8250da576abdf8c86c85a2673817c38f3c883c7a5b736113974c4b56a804174d7fbcdbd198851435f5589d715950427b55180fce70801
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
