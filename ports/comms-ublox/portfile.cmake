#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commschamp/cc.ublox.generated
    REF v1.0
    SHA512 0c487d9409c2f2818024f6232832762527250c3563a5eb5c639ad49943931ceb24616db2432bcd752d1a84820ec5349522510dcd202508641d3f29aef41ca1e5
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOPT_REQUIRE_COMMS_LIB=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME ublox CONFIG_PATH lib/ublox/cmake)
# currently this is only a header only library. after moving lib/ublox to share this lib path will be empty
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL "${CURRENT_PORT_DIR}/copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
