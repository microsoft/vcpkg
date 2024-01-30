vcpkg_download_distfile(ARCHIVE
    URLS "http://download.savannah.nongnu.org/releases/acl/acl-${VERSION}.tar.xz"
         "https://www.mirrorservice.org/sites/download.savannah.gnu.org/releases/acl/acl-${VERSION}.tar.xz"
         
    FILENAME "acl-${VERSION}.tar.xz"
    SHA512 7d02f05d17305f8587ab485395b00c7fdb8e44c1906d0d04b70a43a3020803e8b2b8c707abb6147f794867dfa87bd51769c2d3e11a3db55ecbd2006a6e6231dc
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_list(SET options)
if("nls" IN_LIST FEATURES)
    vcpkg_list(APPEND options "--enable-nls")
    vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gettext/bin")
else()
    set(ENV{AUTOPOINT} true) # true, the program
    vcpkg_list(APPEND options "--disable-nls")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${options}
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/doc/COPYING.LGPL")
