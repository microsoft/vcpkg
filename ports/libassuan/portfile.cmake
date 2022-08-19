set(LIBASSUAN_BRANCH 2.5)
set(LIBASSUAN_VERSION ${LIBASSUAN_BRANCH}.5)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.gnupg.org/ftp/gcrypt/${PORT}/${PORT}-${LIBASSUAN_VERSION}.tar.bz2"
    FILENAME "${PORT}-${LIBASSUAN_VERSION}.tar.bz2"
    SHA512 70117f77aa43bbbe0ed28da5ef23834c026780a74076a92ec775e30f851badb423e9a2cb9e8d142c94e4f6f8a794988c1b788fd4bd2271e562071adf0ab16403
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        find-libgpg-error.patch     # https://github.com/LibreOffice/core/tree/master/external/libassuan
        fix-autoconf-macros.patch
        w32-build-fixes.patch
        w32-build-fixes-2.patch
        w32-stdc.patch              # https://gerrit.libreoffice.org/c/core/+/133339
        versioninfo_obj_extn.patch
        environ.patch               # https://docs.microsoft.com/en-us/cpp/c-runtime-library/environ-wenviron, no support for UWP
                                    # better fix would be to get rid of assuan's own setenv and resort to gnulib's 
)

if (VCPKG_TARGET_IS_WINDOWS)
    list(APPEND EXTRA_OPTS "CFLAGS=\$CFLAGS -D__STDC__=1")
endif()

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --disable-doc
        --disable-silent-rules
        --with-libgpg-error-prefix=${CURRENT_INSTALLED_DIR}/tools/libgpg-error
        ${EXTRA_OPTS}
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libassuan/bin/libassuan-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libassuan/debug/bin/libassuan-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../..")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/COPYING.LIB" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
