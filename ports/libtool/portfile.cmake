vcpkg_fail_port_install(ON_TARGET "Windows")

set(VERSION 2.4.6)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/libtool/libtool-${VERSION}.tar.gz" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/libtool/libtool-${VERSION}.tar.gz"
    FILENAME "libtool-${VERSION}.tar.gz"
    SHA512 3233d81cb2739a54b840a0a82064eebbfaa4fb442fb993a35d6bd41d8395c51f038c90ae048b9252f172d0a5bbfb4b36e2b13d4477001f9ff7d4124237819a18
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE} 
    REF ${VERSION}
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_AUTO_DST
    OPTIONS_DEBUG
        --prefix=${CURRENT_PACKAGES_DIR}/debug
        --bindir=${CURRENT_PACKAGES_DIR}/debug/tools
    OPTIONS_RELEASE
        --prefix=${CURRENT_PACKAGES_DIR}
        --bindir=${CURRENT_PACKAGES_DIR}/tools
)

vcpkg_install_make()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE ${CURRENT_PACKAGES_DIR}/share/info/dir)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)