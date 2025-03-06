vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/gdbm/gdbm-${VERSION}.tar.gz"
         "https://ftpmirror.gnu.org/gdbm/gdbm-${VERSION}.tar.gz"
         "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gdbm/gdbm-${VERSION}.tar.gz"
    FILENAME "gdbm-${VERSION}.tar.gz"
    SHA512 401ff8c707079f21da1ac1d6f4714a87f224b6f41943078487dc891be49f51fd1ac7a32fd599aae0fad185f2c6ba7432616d328fd6aaab068eb54db9562ff7fa
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    libgdbm-compat      ENABLE_GDBM_COMPAT
    readline            ENABLE_READLINE
    memory-mapped-io    ENABLE_MMAP
)

vcpkg_list(SET options
    "--enable-gdbmtool-debug=no"
)

if(${ENABLE_GDBM_COMPAT})
    list(APPEND options "--enable-libgdbm-compat=yes")
endif()

if(NOT ${ENABLE_READLINE})
    list(APPEND options "--without-readline")
endif()

if(NOT ${ENABLE_MMAP})
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
