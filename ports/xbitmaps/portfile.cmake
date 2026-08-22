set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_download_distfile(
    XBITMAPS_ARCHIVE
    URLS "https://xorg.freedesktop.org/archive/individual/data/xbitmaps-${VERSION}.tar.xz"
    FILENAME "xbitmaps-${VERSION}.tar.xz"
    SHA512 7da5e506effdfcf7344fc8209f47c1ec4c2e9f639e677f8701c36e1e5728037357478af3dd030ca93f3e36a3e1eaad1bb97596aba85868f01b52b420b825a10f
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${XBITMAPS_ARCHIVE}"
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
