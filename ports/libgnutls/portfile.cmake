set(GNUTLS_BRANCH 3.6)
set(GNUTLS_VERSION ${GNUTLS_BRANCH}.15)
set(GNUTLS_HASH f757d1532198f44bcad7b73856ce6a05bab43f6fb77fcc81c59607f146202f73023d0796d3e1e7471709cf792c8ee7d436e19407e0601bc0bda2f21512b3b01c)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.gnupg.org/ftp/gcrypt/gnutls/v${GNUTLS_BRANCH}/gnutls-${GNUTLS_VERSION}.tar.xz"
    FILENAME "gnutls-${GNUTLS_VERSION}.tar.xz"
    SHA512 ${GNUTLS_HASH}
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF ${GNUTLS_VERSION}
)

if(VCPKG_TARGET_IS_OSX)
    set(LDFLAGS "-framework CoreFoundation")
else()
    set(LDFLAGS "")
endif()

if ("openssl" IN_LIST FEATURES)
  set(OPENSSL_COMPATIBILITY "--enable-openssl-compatibility")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --disable-doc
        --disable-silent-rules
        --disable-tests
        --disable-maintainer-mode
        --disable-rpath
        --disable-libdane
        --disable-guile
        --with-included-unistring
        --without-p11-kit
        --without-tpm
        ${OPENSSL_COMPATIBILITY}
        "LDFLAGS=${LDFLAGS}"
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
