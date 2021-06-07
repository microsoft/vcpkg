# AVIF depends on AOM, but AOM doesn't support ARM and UWP
vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AOMediaCodec/libavif
    REF v0.9.1
    SHA512 15fa857ee40aeae2ee077d244c6e11a34193f2348e922b5dfa8579a91fa6ceff05c7146e85f9222ebaa6ef2d76e876ea050e8056990cad80850fb4d9581de9a5
    HEAD_REF master
    PATCHES
        disable-source-utf8.patch
        fix-assigning-size_t.patch
        always-install-configs.patch
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
