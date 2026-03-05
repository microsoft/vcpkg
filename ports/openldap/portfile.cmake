vcpkg_download_distfile(ARCHIVE
    URLS "https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-${VERSION}.tgz"
         "https://mirror.eu.oneandone.net/software/openldap/openldap-release/openldap-${VERSION}.tgz"
    FILENAME "openldap-${VERSION}.tgz"
    SHA512 951b510393433114939f386d43e202a62803724f395e4e400a556ca451f90ff1e179fe580b3db51f275859257b32814e66a13145d46f68bded4ff61c1fa37f36
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
set(ENV{SOURCE_DATE_EPOCH} "1659614616")

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
