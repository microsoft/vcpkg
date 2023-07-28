vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/fragglet/lhasa/releases/download/v0.4.0/lhasa-${VERSION}.tar.gz"
    FILENAME "lhasa-${VERSION}.tar.gz"
    SHA512 55d11a9a23e6a9c847166f963bc11dcc7aba0db1e68c44ae6d0ee40e40494484ff797b649a386bea76ea9b4ff8096722283c82b9ad253d784488366c9d73c127
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES fix-out-of-tree-build.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" AND VCPKG_TARGET_IS_WINDOWS)
    # fixes error: libtool: can't build x86_64-pc-mingw32 shared library unless -no-undefined is specified
    list(APPEND OPTIONS "LDFLAGS=\$LDFLAGS -no-undefined")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${OPTIONS}
)

vcpkg_install_make()

vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_UWP)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools")
else()
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(INSTALL "${CURRENT_PORT_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
