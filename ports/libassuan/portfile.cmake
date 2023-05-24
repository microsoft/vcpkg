vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_download_distfile(tarball
    URLS
        "https://gnupg.org/ftp/gcrypt/libassuan/libassuan-${VERSION}.tar.bz2"
        "https://mirrors.dotsrc.org/gcrypt/libassuan/libassuan-${VERSION}.tar.bz2"
        "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/libassuan/libassuan-${VERSION}.tar.bz2"
    FILENAME "libassuan-${VERSION}.tar.bz2"
    SHA512 70117f77aa43bbbe0ed28da5ef23834c026780a74076a92ec775e30f851badb423e9a2cb9e8d142c94e4f6f8a794988c1b788fd4bd2271e562071adf0ab16403
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${tarball}"
    PATCHES
        cross-tools.patch
)

if(VCPKG_CROSSCOMPILING)
    set(ENV{HOST_TOOLS_PREFIX} "${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        --disable-doc
        --disable-silent-rules
        OPTIONS_RELEASE
            "GPG_ERROR_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgpg-error/bin/gpg-error-config"
        OPTIONS_DEBUG
            "GPG_ERROR_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgpg-error/debug/bin/gpg-error-config"
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/libassuan-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/libassuan-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../..")
endif()

if(NOT VCPKG_CROSSCOMPILING)
    file(INSTALL
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/mkheader${VCPKG_TARGET_SUFFIX}"
        DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}"
        USE_SOURCE_PERMISSIONS
    )
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/COPYING.LIB" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
