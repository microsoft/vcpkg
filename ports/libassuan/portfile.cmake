vcpkg_download_distfile(tarball
    URLS
        "https://gnupg.org/ftp/gcrypt/libassuan/libassuan-${VERSION}.tar.bz2"
        "https://mirrors.dotsrc.org/gcrypt/libassuan/libassuan-${VERSION}.tar.bz2"
        "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/libassuan/libassuan-${VERSION}.tar.bz2"
    FILENAME "libassuan-${VERSION}.tar.bz2"
    SHA512 ca33bd0325bbebccb63b6a84cc0aa5c85b25c6275a68df83aeb3f3729b2cd38220198a941c3479bd461f16b7ddb6b558c0664697ca3153c7fb430544303d773f
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
        "GPG_ERROR_CONFIG=no"
    OPTIONS_RELEASE
        "GPGRT_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgpg-error/bin/gpgrt-config"
    OPTIONS_DEBUG
        "GPGRT_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgpg-error/debug/bin/gpgrt-config"
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

set(install_prefix "${CURRENT_INSTALLED_DIR}")
if(VCPKG_HOST_IS_WINDOWS)
    string(REGEX REPLACE "^([a-zA-Z]):/" "/\\1/" install_prefix "${install_prefix}")
endif()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/libassuan-config" "${install_prefix}" "`dirname $0`/../../..")
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/libassuan-config" "${install_prefix}" "`dirname $0`/../../../..")
endif()

if(NOT VCPKG_CROSSCOMPILING)
    file(INSTALL
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/mkheader${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
        DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}"
        USE_SOURCE_PERMISSIONS
    )
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/COPYING.LIB" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
