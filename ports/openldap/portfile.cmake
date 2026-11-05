vcpkg_download_distfile(ARCHIVE
    URLS "https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-${VERSION}.tgz"
         "https://mirror.eu.oneandone.net/software/openldap/openldap-release/openldap-${VERSION}.tgz"
    FILENAME "openldap-${VERSION}.tgz"
    SHA512 a64b222bee2e8693e534f64eeb7afcd1f0c7a4b9ae2288ce2c53be9b532902fac3a1e3318c82545cf30c7f982a68b5167ee8baba1f4be5c1a72abdb7c75ac80b
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        android.diff
        cyrus-sasl.diff
        openssl.patch
        subdirs.patch
)

vcpkg_list(SET FEATURE_OPTIONS)
if("tools" IN_LIST FEATURES)
    vcpkg_list(APPEND FEATURE_OPTIONS --enable-tools)
endif()

if("cyrus-sasl" IN_LIST FEATURES)
    vcpkg_list(APPEND FEATURE_OPTIONS --with-cyrus-sasl)
else()
    vcpkg_list(APPEND FEATURE_OPTIONS --without-cyrus-sasl)
endif()

if(VCPKG_TARGET_IS_ANDROID)
    vcpkg_list(APPEND FEATURE_OPTIONS -with-yielding_select=yes)
elseif(VCPKG_TARGET_IS_EMSCRIPTEN)
    vcpkg_list(APPEND FEATURE_OPTIONS --with-yielding_select=no)
endif()

# Disable build environment details in binaries
# Refresh with `date +%s`
set(ENV{SOURCE_DATE_EPOCH} "1780131797")

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        ${FEATURE_OPTIONS}
        --disable-cleartext
        --disable-mdb
        --disable-relay
        --disable-slapd
        --disable-syncprov
        --with-tls=openssl
        --without-systemd
        --without-fetch
        --without-argon2
        ac_cv_lib_iodbc_SQLDriverConnect=no
        ac_cv_lib_odbc_SQLDriverConnect=no
        ac_cv_lib_odbc32_SQLDriverConnect=no
)

vcpkg_make_install(TARGETS depend install)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
