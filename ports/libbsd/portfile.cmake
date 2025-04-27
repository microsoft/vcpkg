if(VCPKG_TARGET_IS_LINUX)
    message("${PORT} currently requires the following tools and libraries from the system package manager:\n    autoreconf\n\nThis can be installed on Ubuntu systems via apt-get install autoconf")
endif()

vcpkg_download_distfile(
        LIBBSD_ARCHIVE
        URLS "https://libbsd.freedesktop.org/releases/libbsd-0.12.2.tar.xz"
        FILENAME "libbsd-0.12.2.tar.xz"
        SHA512 ce43e4f0486d5f00d4a8119ee863eaaa2f968cae4aa3d622976bb31ad601dfc565afacef7ebade5eba33fff1c329b5296c6387c008d1e1805d878431038f8b21
)
vcpkg_extract_source_archive(
        SOURCE_PATH
        ARCHIVE "${LIBBSD_ARCHIVE}"
)

vcpkg_list(SET MAKE_OPTIONS)
vcpkg_list(SET LIBBSD_LINK_LIBRARIES)
vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        OPTIONS
            ${MAKE_OPTIONS}
)
vcpkg_install_make()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
