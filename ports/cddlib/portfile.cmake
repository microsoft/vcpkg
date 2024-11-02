vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cddlib/cddlib
    REF ${VERSION}
    SHA512 8591ebe9e2a09683bb01b478df6536d1291012927d343013f8593126d3570f7883e125c63c68cd21eeea142a450847dc609e373e39cffb308bed1b56d6342ac1
    HEAD_REF master
    PATCHES
        0001-disable-doc-target.patch  # disable building docs, as they require latex
        0002-disable-dd-log.patch  # windows does not export global variables
)
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    COPY_SOURCE  # ensure generated files are found
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING" "${SOURCE_PATH}/COPYING")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
