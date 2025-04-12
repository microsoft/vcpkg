vcpkg_download_distfile(ARCHIVE
    URLS 
        "https://ftp.gnu.org/gnu/gsasl/gsasl-${VERSION}.tar.gz"
        "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gsasl/gsasl-${VERSION}.tar.gz"
    FILENAME "gsasl-${VERSION}.tar.gz"
    SHA512 62fb4a9383392e4816a036f3e8f408c5161a10723e59f0a8f6df5f72101e0b644787f3b07a71c772628fc4f4050960c842c7500736edacd24313ef654e703bc9
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        remove-tests-examples-docs.patch
)

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(CPPFLAGS_WINDOWS_STATIC "CPPFLAGS=\$CPPFLAGS -DGSASL_STATIC=1")
endif()

set(ENV{AUTOPOINT} true)
set(ENV{GTKDOCIZE} true)
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${CPPFLAGS_WINDOWS_STATIC}
        --disable-nls
        --disable-gssapi
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/gsasl.h" "defined GSASL_STATIC" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
