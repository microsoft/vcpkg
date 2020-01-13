vcpkg_fail_port_install(MESSAGE "${PORT} only supports Mac currently." ON_TARGET "Windows" "Linux")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

set(VERSION 1.16.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/automake/automake-${VERSION}.tar.gz" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/automake/automake-${VERSION}.tar.gz"
    FILENAME "automake-${VERSION}.tar.gz"
    SHA512 47b0120a59e3e020529a6ce750297d7de1156fd2be38db5d101e50120f11b40c28741ecd5eacf2790a9e25386713dcf7717339cfa5d7943d0dbf47c417383448
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE} 
    REF ${VERSION}
)

set(ENV{PATH} "$ENV{PATH}:${CURRENT_INSTALLED_DIR}/tools")

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
