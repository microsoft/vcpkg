vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AOMediaCodec/libavif
    REF f938f6b7dd412ffcbdab1808a265b6375dc7b037 #v0.10.1
    SHA512 d4e01edb9891df0b0abc4a1d621287bce6ba38248a7ae458abd73c268b000557a52a5aa6be1fc715b694c8e48166aee458a371d806d5f28160c50ff653420e79
    HEAD_REF master
    PATCHES
        disable-source-utf8.patch
        fix-compiler-warnings.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
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
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
