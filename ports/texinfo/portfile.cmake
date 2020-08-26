vcpkg_fail_port_install(ON_TARGET "OSX" "Windows" "UWP")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

set(TARGET_VERSION 6.7)
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/texinfo/texinfo-${TARGET_VERSION}.tar.xz"
    FILENAME "binutils-${TARGET_VERSION}.tar.xz"
    SHA512 da55a0d0a760914386393c5e8e864540265d8550dc576f784781a6d72501918e8afce716ff343e5c2a0ce09cf921bfaf0a48ecb49f6182a7d10e920ae3ea17e7
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${TARGET_VERSION}
)

vcpkg_configure_make(
    #AUTOCONFIG
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
