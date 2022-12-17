vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

string(REGEX REPLACE "^([0-9]*[.][0-9]*)[.].*" "\\1" GNUTLS_BRANCH "${VERSION}")
vcpkg_download_distfile(tarball
    URLS
        "https://gnupg.org/ftp/gcrypt/gnutls/v${GNUTLS_BRANCH}/gnutls-${VERSION}.tar.xz"
        "https://mirrors.dotsrc.org/gcrypt/gnutls/v${GNUTLS_BRANCH}/gnutls-${VERSION}.tar.xz"
        "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/gnutls/v${GNUTLS_BRANCH}/gnutls-${VERSION}.tar.xz"
    FILENAME "gnutls-${VERSION}.tar.xz"
    SHA512 4199bcf7c9e3aab2f52266aadceefc563dfe2d938d0ea1f3ec3be95d66f4a8c8e5494d3a800c03dd02ad386dec1738bd63e1fe0d8b394a2ccfc7d6c6a0cc9359
)
vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${tarball}"
    SOURCE_BASE "v${VERSION}"
    PATCHES
        use-gmp-pkgconfig.patch
)

vcpkg_list(SET options)

if("nls" IN_LIST FEATURES)
    vcpkg_list(APPEND options "--enable-nls")
else()
    set(ENV{AUTOPOINT} true) # true, the program
    vcpkg_list(APPEND options "--disable-nls")
endif()
if ("openssl" IN_LIST FEATURES)
    vcpkg_list(APPEND options "--enable-openssl-compatibility")
endif()

if(VCPKG_TARGET_IS_OSX)
    vcpkg_list(APPEND options "LDFLAGS=\$LDFLAGS -framework CoreFoundation")
endif()

set(ENV{GTKDOCIZE} true) # true, the program
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        --disable-dependency-tracking
        --disable-doc
        --disable-guile
        --disable-libdane
        --disable-maintainer-mode
        --disable-silent-rules
        --disable-rpath
        --disable-tests
        --with-brotli=no
        --with-p11-kit=no
        --with-tpm=no
        --with-tpm2=no
        --with-zstd=no
        ${options}
        YACC=false # false, the program - not used here
    OPTIONS_DEBUG
        --disable-tools
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/doc/COPYING"
        "${SOURCE_PATH}/doc/COPYING.LESSER"
)
