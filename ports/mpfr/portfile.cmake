if (VCPKG_TARGET_IS_LINUX)
    message(WARNING "${PORT} currently requires the following packages:\n    autoconf-archive\nThese can be installed on Ubuntu systems via\n    sudo apt-get update -y\n    sudo apt-get install -y autoconf-archive\n")
endif()

set(VERSION 4.1.0)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.mpfr.org/mpfr-${VERSION}/mpfr-${VERSION}.tar.xz" "https://ftp.gnu.org/gnu/mpfr/mpfr-${VERSION}.tar.xz"
    FILENAME "mpfr-${VERSION}.tar.xz"
    SHA512 1bd1c349741a6529dfa53af4f0da8d49254b164ece8a46928cdb13a99460285622d57fe6f68cef19c6727b3f9daa25ddb3d7d65c201c8f387e421c7f7bee6273
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES 
        gmpd.patch
        dll.patch
        src-only.patch
)
file(REMOVE_RECURSE "${SOURCE_PATH}/m4")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    ADDITIONAL_MSYS_PACKAGES autoconf-archive
)

vcpkg_install_make()
vcpkg_copy_pdbs()

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/mpfr.pc" AND VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/mpfr.pc" " -lgmp" " -lgmpd")
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING.LESSER" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
