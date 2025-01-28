vcpkg_download_distfile(ARCHIVE
    URLS 
        "https://ftp.gnu.org/gnu/gsasl/gsasl-${VERSION}.tar.gz"
        "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gsasl/gsasl-${VERSION}.tar.gz"
    FILENAME "gsasl-${VERSION}.tar.gz"
    SHA512 161b8a315862a79807ba067c5ae840175b0d8ec14806aceafc3f92d571713b94d1b8c1a5b188c47bf94a79b9a1f133065f96b087baa5e7f360ae7fb8336381ab
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        remove-tests-examples-docs.patch
        fix-windows-compilation.patch
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
