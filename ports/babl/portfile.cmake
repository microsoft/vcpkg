vcpkg_download_distfile(ARCHIVE
    URLS https://download.gimp.org/pub/babl/0.1/babl-${VERSION}.tar.xz
    FILENAME "babl-${VERSION}.tar.xz"
    SHA512 20e40baa6654785d69642e6e85542968db3c5d08da630adc590ff066a52c5938f4ce8a77c0097e00010a905c8c31d8f131eb0308a3f8b6439ab6be4133eae246
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -Dwith-docs=false
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
