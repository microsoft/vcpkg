vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

set(LIBUNISTRING_FILENAME libunistring-${VERSION}.tar.xz)

vcpkg_download_distfile(ARCHIVE
    URLS
        "https://ftp.gnu.org/gnu/libunistring/${LIBUNISTRING_FILENAME}"
        "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/libunistring/${LIBUNISTRING_FILENAME}"
    FILENAME "${LIBUNISTRING_FILENAME}"
    SHA512 01a4267bbd301ea5c389b17ee918ae5b7d645da8b2c6c6f0f004ff2dead9f8e50cda2c6047358890a5fceadc8820ffc5154879193b9bb8970f3fb1fea1f411d6
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "v${VERSION}"
    PATCHES
        disable-gnulib-fetch.patch
        disable-subdirs.patch
        parallelize-symbol-collection.patch
)

vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    USE_WRAPPERS
    OPTIONS
        "--with-libiconv-prefix=${CURRENT_INSTALLED_DIR}"
    ADDITIONAL_MSYS_PACKAGES
        DIRECT_PACKAGES
            "https://mirror.msys2.org/msys/x86_64/msys2-runtime-3.4.10-2-x86_64.pkg.tar.zst"
            da1fd58e00fb43b17f7191262136fa49829003a8a8bd0d0eee857bdc24c02668363b379a3cdcb098b74872059acd5c3852d95436855e86e094c2e7c26e476716
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

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/share") # fail post-build check
