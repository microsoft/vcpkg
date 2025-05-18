vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO karastojko/mailio
    REF "${VERSION}"
    SHA512 a6697694821fdbcc2b70470bba308609460c5c42caac44c799011843a0d064fb5c9377e04fdd30a100d556aeb8ef8ae2a1453fcdb019307785640e80932dd2db
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMAILIO_BUILD_DOCUMENTATION=OFF
        -DMAILIO_BUILD_EXAMPLES=OFF
        -DMAILIO_BUILD_TESTS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
     CONFIG_PATH lib/cmake/mailio
)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
