vcpkg_download_distfile(ARCHIVE
    URLS "https://ftpmirror.gnu.org/gdbm/gdbm-${VERSION}.tar.gz"
         "https://ftp.gnu.org/gnu/gdbm/gdbm-${VERSION}.tar.gz"
         "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gdbm/gdbm-${VERSION}.tar.gz"
    FILENAME "gdbm-${VERSION}.tar.gz"
    SHA512 66666666666666666666666666666666666666666666666666666666666668888888888888888888888888888888888888888888888888888888888888888888
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
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
