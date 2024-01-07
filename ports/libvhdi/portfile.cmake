set(LIB_FILENAME libvhdi-alpha-${VERSION}.tar.gz)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libyal/libvhdi/releases/download/${VERSION}/${LIB_FILENAME}"
    FILENAME "${LIB_FILENAME}"
    SHA512 5eddbb2ea5800f4427a9763b904b74d1b4a876844f0fb00a8e758c73424171ff7b52a821b1618ea575e9553e6ab357ce80884fab8503dcfc36343a32f80ecd02
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "${VERSION}"
)

if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "msvscpp/libvhdi.sln"
    )
else()
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        COPY_SOURCE
    )

    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/COPYING"
)

vcpkg_copy_pdbs()