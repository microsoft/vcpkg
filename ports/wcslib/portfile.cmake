vcpkg_download_distfile(archive
    URLS "https://www.atnf.csiro.au/computing/software/wcs/wcslib-releases/wcslib-${VERSION}.tar.bz2"
    FILENAME "wcslib-${VERSION}.tar.bz2"
    SHA512 e5b171dcf30eec8f4b32eecb004f7d86bf1a14b622056f52e2d469c1ab1f4856112ba924309ef4bc7c4129aabd10ebc6372a5780f8a7612ec203f22f90e38f16
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${archive}"
)

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    COPY_SOURCE
    OPTIONS
        --disable-flex
        --disable-fortran
        --without-pgplot
        --without-cfitsio
)

vcpkg_make_install(MAKEFILE GNUmakefile)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
