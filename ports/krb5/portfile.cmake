vcpkg_download_distfile(ARCHIVE
    URLS "https://kerberos.org/dist/krb5/1.21/krb5-${VERSION}.tar.gz"
    FILENAME "krb5-${VERSION}.tar.gz"
    SHA512 4e09296b412383d53872661718dbfaa90201e0d85f69db48e57a8d4bd73c95a90c7ec7b6f0f325f6bc967f8d203b256b071c0191facf080aca0e2caec5d0ac49
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}/src"
    AUTOCONFIG
    OPTIONS
        "CFLAGS=-fcommon \$CFLAGS"
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/krb5/cat1")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/krb5/cat5")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/krb5/cat7")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/krb5/cat8")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/krb5/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/krb5/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/var")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/var")

# remove due to absolute path error
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/krb5/bin/compile_et")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/krb5/bin/krb5-config")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/krb5/debug/")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/doc/copyright.rst")
