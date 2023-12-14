vcpkg_download_distfile(ARCHIVE
    URLS "http://git.savannah.gnu.org/cgit/libcdio.git/snapshot/libcdio-release-${VERSION}.tar.gz"
    FILENAME "libcdio-release-${VERSION}.tar.gz"
    SHA512 c67be0f6a86a67cb91e6ac473dae9612732a29f26547a38321ed9d7048bf38549ae98ff65c939221cb30b9bab42a3c05d6e0ae1b7dbaebd7cadf7d25e053ce1a
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
    0001-Remove-doc-from-config-and-make.patch
    0002-Typedef-POSIX-types-on-Windows.patch
    0003-Fix-free-while-still-in-use-in-iso9660.hpp.patch
    0004-src-cdda-player.c-always-use-s-style-format-for-prin.patch
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)
vcpkg_install_make()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/cdio/cdio_config.h" "${CURRENT_BUILDTREES_DIR}" "")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
