vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libfuse/libfuse
    REF "fuse-${VERSION}"
    SHA512 a39bb630f8e57a635980e153b9209a4b804569656feddb46fe8bef02c053533a6037fcc767d03efd5f8bebffed1ff55eb5f49b323ab71e8913008f994cffca77
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dutils=false
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
