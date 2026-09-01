vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO drobilla/zix
    REF "v${VERSION}"
    SHA512 e89e9b0d05b2c536ed0c0e5cea2f4301ee878d8a9e14d9573364611201a201f43de986c05303f786adc31accbc2b31b2833e0ba04dea36fe52ea604e01529f32
    HEAD_REF main
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dbenchmarks=disabled
        -Ddocs=disabled
        -Dtests=disabled
        -Dtests_cpp=disabled
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
