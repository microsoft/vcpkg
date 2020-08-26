vcpkg_fail_port_install(ON_TARGET "OSX" "Windows" "UWP")

set(TARGET_VERSION 2.34)
vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnu.org/gnu/binutils/binutils-${TARGET_VERSION}.tar.xz"
    FILENAME "binutils-${TARGET_VERSION}.tar.xz"
    SHA512 2c7976939dcf5e8c5b7374cccd39bfe803b1bec73c6abfa0eb17c24e1942574c6bdb874c66a092a82adc443182eacd8a5a8001c19a76101f0c7ba40c27de0bbd
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${TARGET_VERSION}
)

message("Please run 'sudo apt install texinfo' before install this package")

set(ENV{C_INCLUDE_PATH} "/")

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS --disable-nls --disable-werror
)

vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
