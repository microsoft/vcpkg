vcpkg_download_distfile(tarball
    URLS
        "https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-${VERSION}.tar.bz2"
        "https://mirrors.dotsrc.org/gcrypt/libgcrypt/libgcrypt-${VERSION}.tar.bz2"
        "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-${VERSION}.tar.bz2"
    FILENAME "libgcrypt-${VERSION}.tar.bz2"
    SHA512 8a8d4c61a6622d8481ceb9edc88ec43f58da32e316f79f8d4775325a48f8936aaa9eb355923b39e2c267b784e9c390600daeb62e0c94f00e30bbadb0d8c0865d
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${tarball}"
    PATCHES
        cross-tools.patch
        upstream-fa21ddc1.patch
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
        "AS=${VCPKG_DETECTED_CMAKE_ASM_COMPILER}"
        "GPG_ERROR_CONFIG=no"
    OPTIONS_RELEASE
        "GPGRT_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgpg-error/bin/gpgrt-config"
    OPTIONS_DEBUG
        "GPGRT_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgpg-error/debug/bin/gpgrt-config"
)

vcpkg_install_make(OPTIONS "CCAS=${VCPKG_DETECTED_CMAKE_ASM_COMPILER}")
vcpkg_fixup_pkgconfig() 
vcpkg_copy_pdbs()

if(NOT VCPKG_CROSSCOMPILING)
    file(INSTALL
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/cipher/gost-s-box${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
        DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}"
        USE_SOURCE_PERMISSIONS
    )
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}")
endif()

set(install_prefix "${CURRENT_INSTALLED_DIR}")
if(VCPKG_HOST_IS_WINDOWS)
    string(REGEX REPLACE "^([a-zA-Z]):/" "/\\1/" install_prefix "${install_prefix}")
endif()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/libgcrypt-config" "${install_prefix}" "`dirname $0`/../../..")
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/libgcrypt-config" "${install_prefix}" "`dirname $0`/../../../..")
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
