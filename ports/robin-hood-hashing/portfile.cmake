# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinus/robin-hood-hashing
    REF 3.9.1
    SHA512 dbd614b772171d3e1d47e01513b3aa56d086a0530bad80931dbee4c3674e08c31cb023ac2cd3e9cadd86db76856ccc4c7a0fa9f7cd653044cd68c82e1a4c9c9c
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/src/include/robin_hood.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)