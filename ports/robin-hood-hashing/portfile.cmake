# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinus/robin-hood-hashing
    REF 3.8.0
    SHA512 f64635a2fc3ebd975d40dc4fd3e3df81a6bed11e8bb9df1d6d100e408c2c81da2679e9836313444e573c6bfb160eeecd7fde68988e9d0246601c8993ecc42085
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/src/include/robin_hood.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)