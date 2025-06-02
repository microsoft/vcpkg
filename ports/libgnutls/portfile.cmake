string(REGEX REPLACE "^([0-9]*[.][0-9]*)[.].*" "\\1" GNUTLS_BRANCH "${VERSION}")
vcpkg_download_distfile(tarball
    URLS
        "https://gnupg.org/ftp/gcrypt/gnutls/v${GNUTLS_BRANCH}/gnutls-${VERSION}.tar.xz"
        "https://mirrors.dotsrc.org/gcrypt/gnutls/v${GNUTLS_BRANCH}/gnutls-${VERSION}.tar.xz"
        "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/gnutls/v${GNUTLS_BRANCH}/gnutls-${VERSION}.tar.xz"
    FILENAME "gnutls-${VERSION}.tar.xz"
    SHA512 429cea78e227d838105791b28a18270c3d2418bfb951c322771e6323d5f712204d63d66a6606ce9604a92d236a8dd07d651232c717264472d27eb6de26ddc733
)
vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${tarball}"
    SOURCE_BASE "v${VERSION}"
    PATCHES
        ccasflags.patch
        use-gmp-pkgconfig.patch
        compression-libs.diff
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

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_list(APPEND options "LIBS=\$LIBS -liconv -lcharset") # for libunistring
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_list(APPEND options "ac_cv_dlopen_soname_works=no") # ensure vcpkg libs
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
        --disable-rpath
        --disable-tests
        --with-brotli=no
        --with-p11-kit=no
        --with-tpm=no
        --with-tpm2=no
        --with-zstd=no
        --with-zlib=yes
        ${options}
        YACC=false # false, the program - not used here
    OPTIONS_DEBUG
        --disable-tools
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/doc/COPYING"
        "${SOURCE_PATH}/doc/COPYING.LESSER"
)
