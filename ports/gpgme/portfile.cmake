vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_download_distfile(tarball
    URLS
        "https://gnupg.org/ftp/gcrypt/gpgme/gpgme-${VERSION}.tar.bz2"
        "https://mirrors.dotsrc.org/gcrypt/gpgme/gpgme-${VERSION}.tar.bz2"
        "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/gpgme/gpgme-${VERSION}.tar.bz2"
    FILENAME "gpgme-${VERSION}.tar.bz2"
    SHA512 c0cb0b337d017793a15dd477a7f5eaef24587fcda3d67676bf746bb342398d04792c51abe3c26ae496e799c769ce667d4196d91d86e8a690d02c6718c8f6b4ac
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${tarball}"
    PATCHES
        disable-tests.patch
        disable-docs.patch
        fix-c++11.patch # https://git.gnupg.org/cgi-bin/gitweb.cgi?p=gpgme.git;a=commit;h=f02c20cc9c5756690b07abfd02a43533547ba2ef
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
        --with-libgpg-error-prefix=${CURRENT_INSTALLED_DIR}/tools/libgpg-error
        --with-libassuan-prefix=${CURRENT_INSTALLED_DIR}/tools/libassuan
)

vcpkg_install_make()
# CMake config needs work for linkage and build type
# vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Gpgmepp PACKAGE_NAME Gpgmepp)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake" "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
vcpkg_copy_pdbs() 
# We have no dependency on glib, so remove this extra .pc file
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gpgme-glib.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gpgme-glib.pc")
vcpkg_fixup_pkgconfig()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/gpgme/bin/gpgme-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")
if (NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/gpgme/debug/bin/gpgme-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../..")
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
