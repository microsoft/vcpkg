# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO p-ranav/csv2
    REF a20992f7a1b75215609037c4cc66f690e8691aab
    SHA512 4459f34d3d3d2c256743d93dd9c66ac584366120e3c8829173e6f047bf7dce2b08284c82af360a274dea0d43f5d6e1c84bcae51bf4de97751cf41a2fd48cb62b
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

vcpkg_fixup_pkgconfig()
