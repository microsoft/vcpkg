#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commschamp/cc.ublox.generated
    REF v${VERSION}
    SHA512 18ce224f1e4ec86e5b19c948f76d6adee3e0d0344218025bef82ae08b2937c863de107161fab38cc8c959c944876c510e9df249a8aa26132e6c099069a2dd713
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOPT_REQUIRE_COMMS_LIB=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME cc_ublox CONFIG_PATH lib/cc_ublox/cmake)
# currently this is only a header only library. after moving lib/ublox to share this lib path will be empty
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL "${CURRENT_PORT_DIR}/copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
