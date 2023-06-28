vcpkg_download_distfile(archive
    URLS "https://www.atnf.csiro.au/people/mcalabre/WCS/wcslib-7.12.tar.bz2"
    FILENAME "wcslib-7.12.tar.bz2"
    SHA512 7f38f725992d3c4bd3c1b908d494ac361c17f6b60f091d987fda596211423bb7396b3a5e2f1f6dd6215835016d302083472a7ad0822f17cdfe230c8f556b3e23
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
