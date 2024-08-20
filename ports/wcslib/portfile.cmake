vcpkg_download_distfile(archive
    URLS "http://www.atnf.csiro.au/people/mcalabre/WCS/wcslib-8.2.1.tar.bz2"
    FILENAME "wcslib-8.2.1.tar.bz2"
    SHA512 0d1ab63445974c2a4f425225cde197866187a9e7ae0195a33dcb33ad299018294338bc16ab4cbe6a3a27fb40aded75c60377348eaa91713d16a934cd95532c25
)

vcpkg_extract_source_archive(
    src
    ARCHIVE "${archive}"
)

vcpkg_configure_make(
    SOURCE_PATH ${src}
    COPY_SOURCE
    OPTIONS
        --disable-flex
        --disable-fortran
        --without-pgplot
        --without-cfitsio)

vcpkg_install_make(MAKEFILE GNUmakefile)
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${src}/COPYING")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
