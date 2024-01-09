vcpkg_download_distfile(ARCHIVE
    URLS "https://www.gaia-gis.it/gaia-sins/freexl-sources/freexl-${VERSION}.tar.gz"
    FILENAME "freexl-${VERSION}.tar.gz"
    SHA512 663ccc321c2f0dcab8ad9255b2a77066c2046d531a0aa723fb114301fa27b53bf980787dd2548c46541036eceef988c5eedf2bec053adf628929470e67ddc17a
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        dependencies.patch
        subdirs.patch
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)
vcpkg_install_make()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/freexl.pc" " -lm" " -liconv -lcharset")
    if(NOT DEFINED VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/freexl.pc" " -lm" " -liconv -lcharset")
    endif()
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
