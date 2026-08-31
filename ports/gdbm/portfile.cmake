vcpkg_download_distfile(ARCHIVE
    URLS "https://ftpmirror.gnu.org/gdbm/gdbm-${VERSION}.tar.gz"
         "https://ftp.gnu.org/gnu/gdbm/gdbm-${VERSION}.tar.gz"
         "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gdbm/gdbm-${VERSION}.tar.gz"
    FILENAME "gdbm-${VERSION}.tar.gz"
    SHA512 44aafe254f0950a8f5215d8f1337674f07b19f2a375f6eb19a7e39690028c80c3774b705c2b76b470ae74042b21f2ca77d02f6f57aa2ee50296db801220a3352
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fix-readline-linkage.patch
)

vcpkg_list(SET options)

if("libgdbm-compat" IN_LIST FEATURES)
    list(APPEND options "--enable-libgdbm-compat=yes")
endif()

if("readline" IN_LIST FEATURES)
    list(APPEND options "--with-readline")
else()
    list(APPEND options "--without-readline")
endif()

if("memory-mapped-io" IN_LIST FEATURES)
    list(APPEND options "--enable-memory-mapped-io")
else()
    list(APPEND options "--disable-memory-mapped-io")
endif()

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    COPY_SOURCE
    OPTIONS
        ${options}
)

vcpkg_make_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/gdbm/info"
    "${CURRENT_PACKAGES_DIR}/share/gdbm/locale"
    "${CURRENT_PACKAGES_DIR}/share/gdbm/man1"
    "${CURRENT_PACKAGES_DIR}/share/gdbm/man3"
)
