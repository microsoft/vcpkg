vcpkg_download_distfile(ARCHIVE
    URLS "https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.5.13.tgz"
    FILENAME "openldap-2.5.13.tgz"
    SHA512 30fdc884b513c53169910eec377c2ad05013b9f06bab3123d50d028108b24548791f7f47f18bcb3a2b4868edeab02c10d81ffa320c02d7b562f2e8f2fa25d6c9
)

vcpkg_list(SET EXTRA_PATCHES)

# Check autoconf version < 2.70
execute_process(COMMAND autoconf --version OUTPUT_VARIABLE AUTOCONF_VERSION_STR)
if(NOT "${AUTOCONF_VERSION_STR}" STREQUAL "" AND "${AUTOCONF_VERSION_STR}" MATCHES ".*2\\.[0-6].*")
    vcpkg_list(APPEND EXTRA_PATCHES m4.patch)
endif()

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        openssl.patch
        subdirs.patch
        ${EXTRA_PATCHES}
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

# Disable build environment details in binaries
set(ENV{SOURCE_DATE_EPOCH} "1659614616")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_VERBOSE_FLAGS
    AUTOCONFIG
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

vcpkg_build_make(BUILD_TARGET depend LOGFILE_ROOT depend)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
