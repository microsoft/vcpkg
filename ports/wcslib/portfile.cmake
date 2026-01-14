vcpkg_download_distfile(archive
    URLS "https://www.atnf.csiro.au/computing/software/wcs/wcslib-releases/wcslib-${VERSION}.tar.bz2"
    FILENAME "wcslib-${VERSION}.tar.bz2"
    SHA512 f63fe02d89b9296f2502dfb2e3715a0c20c1393d057396af9db7e0c240a6585faacb43c12c5e9456dc5e4ccec009b9d0a2534262515f5c83f11644fabe3d5a7f
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${archive}"
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    COPY_SOURCE
    OPTIONS
        --disable-flex
        --disable-fortran
        --without-pgplot
        --without-cfitsio)

vcpkg_install_make(MAKEFILE GNUmakefile)
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
