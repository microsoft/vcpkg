vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO randy408/libspng
    REF v0.6.3
    SHA512 857ff6ba51d8e338b1c96a0c016aaea3aea807aaea935cc14959d3d0c337229dfb328279d042ddf937152dd0c496e5bcddbc9fa50ac167e4b31847950cc043da
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libspng RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")