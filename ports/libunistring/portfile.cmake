vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

set(LIBUNISTRING_FILENAME libunistring-${VERSION}.tar.xz)

vcpkg_download_distfile(ARCHIVE
    URLS
        "https://ftp.gnu.org/gnu/libunistring/${LIBUNISTRING_FILENAME}"
        "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/libunistring/${LIBUNISTRING_FILENAME}"
    FILENAME "${LIBUNISTRING_FILENAME}"
    SHA512 5fbb5a0a864db73a6d18cdea7b31237da907fff0ef288f3a8db6ebdba8ef61ad8855e5fc780c2bbf632218d8fa59dd119734e5937ca64dc77f53f30f13b80b17
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "v${VERSION}"
    PATCHES
        disable-gnulib-fetch.patch
        disable-subdirs.patch
        parallelize-symbol-collection.patch
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    USE_WRAPPERS
    OPTIONS
        "--with-libiconv-prefix=${CURRENT_INSTALLED_DIR}"
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(
    COMMENT [[
The libunistring library and its header files are dual-licensed under
"the GNU LGPLv3+ or the GNU GPLv2+".
]]
    FILE_LIST
        "${SOURCE_PATH}/COPYING.LIB"
        "${SOURCE_PATH}/COPYING"
)
