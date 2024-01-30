vcpkg_download_distfile(ARCHIVE
    URLS "https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v${VERSION}/util-linux-${VERSION}.tar.xz"
    FILENAME "util-linux-${VERSION}.tar.xz"
    SHA512 3d59a0f114c06be19ef7f86fca37ba5b9073823d011b3fc37997ddb00124b4505ea32903b78798a64dffbccf0ba645a692678ee845cc65a5b321824448a82a94
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE ${VERSION}
)

set(ENV{GTKDOCIZE} true)

vcpkg_list(SET options)
if("nls" IN_LIST FEATURES)
    vcpkg_list(APPEND options "--enable-nls")
else()
    set(ENV{AUTOPOINT} true) # true, the program
    vcpkg_list(APPEND options "--disable-nls")
endif()

vcpkg_configure_make(
    AUTOCONFIG
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

vcpkg_install_make()
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
