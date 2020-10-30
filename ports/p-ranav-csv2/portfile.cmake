# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO p-ranav/csv2
    REF d659f90b637bb0de6c32246583fc4bb7caade215
    SHA512 d00b1356907a7e22529e3ac4a7b979c6868311e8a98e4fd8b0a8b1f0d94b2425854242649a80a933084202834f5cee1fe17b51476fcc17e87b00e1e3cb8ed0e9
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCSV2_BUILD_TESTS=OFF
        -DCSV2_SAMPLES=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/share/licenses)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/LICENSE.mio DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
