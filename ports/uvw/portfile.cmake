#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skypjack/uvw
    REF v1.15.0_libuv-v1.27
    SHA512 acf1f1bdbc34ec5d040514ca08c99ee05b5bbb112828a4acf5f4c50e1910d2c74864a0793d4087b7a4a0704dd2ba1a973f65cee032fffea9247009be9cd0243c
)

file(INSTALL
    ${SOURCE_PATH}/src/uvw
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

file(INSTALL
    ${SOURCE_PATH}/src/uvw.hpp
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright/readme/package files
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/uvw RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/uvw)
