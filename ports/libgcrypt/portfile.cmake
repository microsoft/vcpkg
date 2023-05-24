vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_download_distfile(tarball
    URLS
        "https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-${VERSION}.tar.bz2"
        "https://mirrors.dotsrc.org/gcrypt/libgcrypt/libgcrypt-${VERSION}.tar.bz2"
        "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-${VERSION}.tar.bz2"
    FILENAME "libgcrypt-${VERSION}.tar.bz2"
    SHA512 e5ca7966624fff16c3013795836a2c4377f0193dbb4ac5ad2b79654b1fa8992e17d83816569a402212dc8367a7980d4141f5d6ac282bae6b9f02186365b61f13
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

vcpkg_list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DVCPKG_LANGUAGES=ASM;C")
vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --disable-doc
        --disable-silent-rules
        "AS=${VCPKG_DETECTED_CMAKE_ASM_COMPILER}"
    OPTIONS_RELEASE
        "GPG_ERROR_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgpg-error/bin/gpg-error-config"
    OPTIONS_DEBUG
        "GPG_ERROR_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgpg-error/debug/bin/gpg-error-config"
)

vcpkg_install_make(OPTIONS "CCAS=${VCPKG_DETECTED_CMAKE_ASM_COMPILER}")
vcpkg_fixup_pkgconfig() 
vcpkg_copy_pdbs()

if(NOT VCPKG_CROSSCOMPILING)
    file(INSTALL
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/cipher/gost-s-box${VCPKG_TARGET_SUFFIX}"
        DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}"
        USE_SOURCE_PERMISSIONS
    )
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}")
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/libgcrypt-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/libgcrypt-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../..")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(COMMENT [[
The library is distributed under the terms of the GNU Lesser General Public License (LGPL).
The helper programs as well as the documentation are distributed under the terms of the GNU General Public License (GPL).
There are additonal notices about contributions that require these additional notices are distributed.
]]
    FILE_LIST
        "${SOURCE_PATH}/COPYING.LIB"
        "${SOURCE_PATH}/COPYING"
        "${SOURCE_PATH}/LICENSES"
)
