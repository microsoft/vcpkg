vcpkg_download_distfile(tarball
    URLS
        "https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-${VERSION}.tar.bz2"
        "https://mirrors.dotsrc.org/gcrypt/libgpg-error/libgpg-error-${VERSION}.tar.bz2"
        "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-${VERSION}.tar.bz2"
    FILENAME "libgpg-error-${VERSION}.tar.bz2"
    SHA512 d3f6ca9d9abefe81f5cbbc195fbe259d3362119018c535ad2621ee407cad3487011325a9f4c4a15442a9ac5a0fe7ce86dafd7b3d891a446516362ba6b7b9047b
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${tarball}"
    PATCHES
        android.diff
        cross-tools.patch
        gpgrt-config.patch
        mingw.diff
        pkgconfig-libintl.patch
        win32-nls.diff
)

vcpkg_list(SET options)
if("nls" IN_LIST FEATURES)
    vcpkg_list(APPEND options "--enable-nls")
else()
    set(ENV{AUTOPOINT} true) # true, the program
    vcpkg_list(APPEND options "--disable-nls")
endif()

if(VCPKG_CROSSCOMPILING)
    set(ENV{HOST_TOOLS_PREFIX} "${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}")
endif()

if(VCPKG_TARGET_IS_EMSCRIPTEN)
    vcpkg_list(APPEND options "--disable-threads")
endif()

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        ${options}
        --disable-doc
        --disable-tests
)

vcpkg_make_install()
vcpkg_fixup_pkgconfig() 
vcpkg_copy_pdbs()

if(NOT VCPKG_CROSSCOMPILING)
    file(INSTALL
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/mkerrcodes${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/mkheader${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
        DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}"
        USE_SOURCE_PERMISSIONS
    )
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
if(NOT "nls" IN_LIST FEATURES)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/locale")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LIB")
