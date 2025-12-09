string(REGEX REPLACE "\\.[0-9]+$" "" MAJOR_MINOR ${VERSION})

# Keep distfile, don't use GitLab!
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/pangomm/${MAJOR_MINOR}/pangomm-${VERSION}.tar.xz"
    FILENAME "pangomm-${VERSION}.tar.xz"
    SHA512 3000126cdf538f43c131a186999fd39d81ec471f5770d8dfd721ff84cb3f5ad44d17cdcc732299ee9d9f34f2dd1279959cf6e1b863c3a0afc32e49b453db782b
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dmsvc14x-parallel-installable=false
        -Dbuild-documentation=false
    ADDITIONAL_BINARIES
        glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
        glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
