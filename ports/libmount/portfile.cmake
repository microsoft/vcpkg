string(REGEX MATCH "^([0-9]+\\.[0-9]+)" VERSION_SHORT "${VERSION}")

vcpkg_download_distfile(ARCHIVE
    URLS "https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v${VERSION_SHORT}/util-linux-${VERSION}.tar.xz"
    FILENAME "util-linux-${VERSION}.tar.xz"
    SHA512 7415add0be2930654e322830808dde03ff6d511bd357f0679e6b6287a13ca79fe58ce4ac05edef86b76fb381b3a36ca2da9d3c31b5dc0a1d889c203156a57277
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE ${VERSION}
    PATCHES
        hide-private-symbols.diff
)

set(ENV{GTKDOCIZE} true)

vcpkg_list(SET options)
if("nls" IN_LIST FEATURES)
    vcpkg_list(APPEND options "--enable-nls")
else()
    set(ENV{AUTOPOINT} true) # true, the program
    vcpkg_list(APPEND options "--disable-nls")
endif()
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    vcpkg_list(APPEND options "--disable-year2038")
endif()

vcpkg_make_configure(
    AUTORECONF
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
        --disable-asciidoc
        --disable-all-programs
        --disable-dependency-tracking
        --enable-libmount
        --enable-libblkid
        "--mandir=${CURRENT_PACKAGES_DIR}/share/man"
)

vcpkg_make_install()
vcpkg_fixup_pkgconfig()


file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/bin"
    "${CURRENT_PACKAGES_DIR}/debug/sbin"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/bin"
    "${CURRENT_PACKAGES_DIR}/sbin"
    "${CURRENT_PACKAGES_DIR}/share"
    "${CURRENT_PACKAGES_DIR}/tools"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/README.licensing" "${SOURCE_PATH}/COPYING")
