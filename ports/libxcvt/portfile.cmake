vcpkg_download_distfile(
    LIBXCVT_ARCHIVE
    URLS "https://www.x.org/releases/individual/lib/libxcvt-${VERSION}.tar.xz"
    FILENAME "libxcvt-${VERSION}.tar.xz"
    SHA512 2fecc784375e69b6e8e46608618a5f5a8ad20ecd5229fd093883fe401dd6ea231d8b77c6753756fff01f3040bef2db60a042d40fc349769ef5348e5cd9ed1f28
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${LIBXCVT_ARCHIVE}"
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_tools(TOOL_NAMES cvt AUTO_CLEAN)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
