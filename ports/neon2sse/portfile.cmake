vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/ARM_NEON_2_x86_SSE
    REF ed59be8546632d5126ff69c87122ae5de20ffe4f
    SHA512 711257e66d7d711a54b2742b738fbfea225ff4778af5c4792a0eaa6caab6922f131b16dbb743936aaf3393186eeccd3a8615e6eb35f4787b55c8b3d3d5cfc95a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME NEON_2_SSE CONFIG_PATH lib/cmake/NEON_2_SSE)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug"
                    "${CURRENT_PACKAGES_DIR}/lib"
)
