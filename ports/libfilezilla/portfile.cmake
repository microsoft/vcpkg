vcpkg_download_distfile(ARCHIVE
    # Cannot put link from official source code. They put protection against automatic downloads.
    URLS "https://snapshot.debian.org/archive/debian/20241024T205158Z/pool/main/libf/libfilezilla/libfilezilla_${VERSION}.debian.tar.xz"
    FILENAME "libfilezilla-${VERSION}.tar.gz"
    SHA512 75d9d803832a668663458d22cf09153da33948cb30acaa9bb6f61c0a667d1b879bc231ad68b8d1f18b854f85215774124ca0be2e0cb6cabd2f6abfcf4f99e531
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --disable-locales
)

vcpkg_make_install()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
