set(FREEXL_VERSION_STR "1.0.6")

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.gaia-gis.it/gaia-sins/freexl-sources/freexl-${FREEXL_VERSION_STR}.tar.gz"
    FILENAME "freexl-${FREEXL_VERSION_STR}.tar.gz"
    SHA512 efbbe261e57d5c05167ad8e1d5a5b348a7e702c0a4030b18dd2a8c60a38332caccbb073ff604bdf5bafac827310b41c7b79f9fa519ea512d6de2eafd9c1f71f6
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fix-makefiles.patch
        fix-sources.patch
        fix-pc-file.patch
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)
vcpkg_install_make()

if(VCPKG_TARGET_IS_WINDOWS)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(includedir [[${prefix}/include]])
        set(outfile "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/freexl.pc")
        vcpkg_replace_string("${outfile}" " -lm" " -liconv -lcharset")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        set(includedir [[${prefix}/../include]])
        set(outfile "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/freexl.pc")
        vcpkg_replace_string("${outfile}" " -lm" " -liconv -lcharset")
    endif()
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
