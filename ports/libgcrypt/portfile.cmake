vcpkg_download_distfile(tarball
    URLS
        "https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-${VERSION}.tar.bz2"
        "https://mirrors.dotsrc.org/gcrypt/libgcrypt/libgcrypt-${VERSION}.tar.bz2"
        "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-${VERSION}.tar.bz2"
    FILENAME "libgcrypt-${VERSION}.tar.bz2"
    SHA512 8e093e69e3c45d30838625ca008e995556f0d5b272de1c003d44ef94633bcc0d0ef5d95e8725eb531bfafb4490ac273488633e0c801200d4666194f86c3e270e
)
vcpkg_download_distfile(osx_asm_patch
    URLS "https://github.com/gpg/libgcrypt/commit/bb0895bbb7c6d2b9502cbbf03da14d4ecf27a183.patch?full_index=1"
    FILENAME "libgcrypt-1.11.0-bb0895b.diff"
    SHA512 dc9a0f0c13b08bdc6e28b966c61f5a8695bc58a7bf5ea5a8376f3b293bde729f485342eabbc84e78ab37afaf12ba1ac4385f0baff0f5f4b31bc1d3b764893522
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${tarball}"
    PATCHES
        cross-tools.patch
        "${osx_asm_patch}"
)

if(VCPKG_CROSSCOMPILING)
    set(ENV{HOST_TOOLS_PREFIX} "${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}")
endif()

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/libgpg-error/aclocal/\"")
vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    LANGUAGES C ASM
    OPTIONS
        --disable-doc
    OPTIONS_RELEASE
        "GPG_ERROR_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgpg-error/bin/gpgrt-config gpg-error"
        "GPGRT_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgpg-error/bin/gpgrt-config"
    OPTIONS_DEBUG
        "GPG_ERROR_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgpg-error/debug/bin/gpgrt-config gpg-error"
        "GPGRT_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgpg-error/debug/bin/gpgrt-config"
)

vcpkg_make_install()
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
