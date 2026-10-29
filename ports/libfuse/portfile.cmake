vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libfuse/libfuse
    REF "fuse-${VERSION}"
    SHA512 48b4d1c68d9e82377d2e854cfc3be1b437fe72acd09a4970b5692ac1d5808162db77524f495924d2e369243446aa496bdc9d2a87246fa677c15bf115434e6540
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
