set(LIBUNISTRING_VERSION 0.9.10)
set(LIBUNISTRING_FILENAME libunistring-${LIBUNISTRING_VERSION}.tar.gz)

vcpkg_download_distfile(ARCHIVE
    URLS
        "https://ftp.gnu.org/gnu/libunistring/${LIBUNISTRING_FILENAME}"
        "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/libunistring/${LIBUNISTRING_FILENAME}"
    FILENAME "${LIBUNISTRING_FILENAME}"
    SHA512 690082732fbbd47ab4ffbd6f21d85afece0f8e2ded24982f949f4ae52bf0a981b75ea9bc14ab289e0954cde07f31a7a4c2bb65615a8eb5b2bfa65720310b6fc9
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF ${LIBUNISTRING_VERSION}
    PATCHES libunistring-msys-msvc-build.patch
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    COPY_SOURCE
    USE_WRAPPERS
    OPTIONS
        "--with-libiconv-prefix=${CURRENT_INSTALLED_DIR}"
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# copyright excerpt from README, to cover dual license under "LGPLv3+ or GPLv2".
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING.LIB" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
