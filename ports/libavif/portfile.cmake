# AVIF depends on AOM, but AOM doesn't support ARM and UWP
vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AOMediaCodec/libavif
    REF v0.9.2
    SHA512 04400ae76214d2f0361a14897d6ee97be675375865bb96c8d237e9a4a1152ac1a966db903c11df82da71b0bc68599a5857e038cc90d63c5d3bc77b13169a3e75
    HEAD_REF master
    PATCHES
        disable-source-utf8.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DAVIF_CODEC_AOM=ON
        -DAVIF_BUILD_APPS=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

# Move cmake configs
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

# Fix pkg-config files
vcpkg_fixup_pkgconfig()

# Remove duplicate files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
