vcpkg_fail_port_install(ON_TARGET "Windows")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

set(VERSION 2.69)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/autoconf/autoconf-${VERSION}.tar.gz" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/autoconf/autoconf-${VERSION}.tar.gz"
    FILENAME "autoconf-${VERSION}.tar.gz"
    SHA512 e34c7818bcde14d2cb13cdd293ed17d70740d4d1fd7c67a07b415491ef85d42f450d4fe5f8f80cc330bf75c40a62774c51a4336e06e8da07a4cbc49922d975ee
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE} 
    REF ${VERSION}
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    NO_DEBUG
    DISABLE_AUTO_DST
    OPTIONS
        --prefix=${CURRENT_PACKAGES_DIR}
        --bindir=${CURRENT_PACKAGES_DIR}/tools
)

vcpkg_install_make()

file(REMOVE ${CURRENT_PACKAGES_DIR}/share/info/dir)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)