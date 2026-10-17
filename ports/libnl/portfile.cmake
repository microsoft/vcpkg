vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/thom311/libnl/releases/download/libnl3_12_0/libnl-${VERSION}.tar.gz"
    FILENAME "libnl-${VERSION}.tar.gz"
    SHA512 6230b8cab608355346030cf32f37c43983b1d1b632cb7677ae383d4f2369b4a3773b35d2d51007d3b9c16f333aaf351682c4602b3d229cd602eec5ad53efd6f3
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fix-static-tc-kind-registration.patch
        install-headers-into-include.patch
)

# flex and bison are required to generate lib/route/{pktloc_*,ematch_*}.c
vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_DIR "${BISON}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${BISON_DIR}")

# Upstream defaults to --enable-cli, whose plugin loader bakes an absolute
# pkglibdir into the binary; the port ships the libraries only.
vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --disable-cli
        --disable-dependency-tracking
)
vcpkg_make_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/etc"
    "${CURRENT_PACKAGES_DIR}/debug/etc"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
file(INSTALL "${SOURCE_PATH}/etc/pktloc" "${SOURCE_PATH}/etc/classid"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
