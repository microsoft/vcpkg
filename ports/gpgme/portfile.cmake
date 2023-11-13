vcpkg_download_distfile(tarball
    URLS
        "https://gnupg.org/ftp/gcrypt/gpgme/gpgme-${VERSION}.tar.bz2"
        "https://mirrors.dotsrc.org/gcrypt/gpgme/gpgme-${VERSION}.tar.bz2"
        "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/gpgme/gpgme-${VERSION}.tar.bz2"
    FILENAME "gpgme-${VERSION}.tar.bz2"
    SHA512 17053053fa885f01416433e43072ac716b5d5db0c3edf45b2d6e90e6384d127626e6ae3ce421abba8f449f5ca7e8963f3d62f3565d295847170bc998d1ec1a70
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${tarball}"
    PATCHES
        disable-docs.patch
 )

vcpkg_list(SET LANGUAGES)
if("cpp" IN_LIST FEATURES)
    vcpkg_list(APPEND LANGUAGES "cpp")
endif()

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --disable-gpgconf-test
        --disable-gpg-test
        --disable-gpgsm-test
        --disable-g13-test
        --enable-languages=${LANGUAGES}
        GPG_ERROR_CONFIG=/ # fake absolute path; gpgrt-config is used instead
    OPTIONS_RELEASE
        "GPGRT_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgpg-error/bin/gpgrt-config"
    OPTIONS_DEBUG
        "GPGRT_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgpg-error/debug/bin/gpgrt-config"
)

vcpkg_install_make()
vcpkg_copy_pdbs() 

# This port doesn't support the windows-only glib integration.
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gpgme-glib.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gpgme-glib.pc")
vcpkg_fixup_pkgconfig()

# CMake config needs work for linkage and build type.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake" "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")

set(install_prefix "${CURRENT_INSTALLED_DIR}")
if(VCPKG_HOST_IS_WINDOWS)
    string(REGEX REPLACE "^([a-zA-Z]):/" "/\\1/" install_prefix "${install_prefix}")
endif()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/gpgme-config" "${install_prefix}" "`dirname $0`/../../..")
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/gpgme-config" "${install_prefix}" "`dirname $0`/../../../..")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(COMMENT [[
The library is distributed under the terms of the GNU Lesser General Public License (LGPL).
The helper programs are distributed under the terms of the GNU General Public License (GPL).
There are additonal notices about contributions that require these additional notices are distributed.
]]
    FILE_LIST
        "${SOURCE_PATH}/COPYING.LESSER"
        "${SOURCE_PATH}/COPYING"
        "${SOURCE_PATH}/LICENSES"
)
