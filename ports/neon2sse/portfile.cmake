vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/ARM_NEON_2_x86_SSE
    REF a1652fd5253afbf3e39357b012974f93511f6108
    SHA512 9f8aa283e48eb3b615da3d89ec4165d1ec9599e8e181059c2b9acb2921ce753ce0f29b8c321d7d6661f10eb67e234c629df75853b87c4139a9bb137dbb3f4fc1
    PATCHES
        fix-cmakelists.patch # rename `NEON_2_SSE` to `neon2sse`
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug"
                    "${CURRENT_PACKAGES_DIR}/lib"
)
