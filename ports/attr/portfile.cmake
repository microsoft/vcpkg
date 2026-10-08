vcpkg_download_distfile(ARCHIVE
    URLS "https://download.savannah.nongnu.org/releases/attr/attr-${VERSION}.tar.xz"
         "https://www.mirrorservice.org/sites/download.savannah.gnu.org/releases/attr/attr-${VERSION}.tar.xz"
    FILENAME "attr-${VERSION}.tar.xz"
    SHA512 870d0c34fbaa7520aad058ecd6509fe8eddd17430781a16d1e80484d4947307a7c641f0449183cbac1da611a85f82c9bee2d2d7bff76170fc2195b123100d22e
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_list(SET options)
if("nls" IN_LIST FEATURES)
    vcpkg_list(APPEND options "--enable-nls")
    vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gettext/bin")
else()
    set(ENV{AUTOPOINT} true) # true, the program
    vcpkg_list(APPEND options "--disable-nls")
endif()

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        ${options}
)

vcpkg_make_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/etc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/doc/COPYING.LGPL")
