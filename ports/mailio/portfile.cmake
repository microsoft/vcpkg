vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO karastojko/mailio
    REF "${VERSION}"
    SHA512 5a63eb87fdb2a583aaa1de5f8a02facceacaf4174cdb96faafed992899396921eb3b232359ca49bf40ce2cdb414113cb88bf8a71c69bbc2e74f56dab9e8ee06c
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
