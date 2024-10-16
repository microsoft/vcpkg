# Keep distfile, don't use GitLab!
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/pangomm/2.54/pangomm-2.54.0.tar.xz"
    FILENAME "pangomm-2.54.0.tar.xz"
    SHA512 bc74be8d1c692815fe07e41c75386a2fb8038ba2a335cad488bf996ecc18f1e1b434ef4bd6c15a9c5b5c42f4349c98403acc96a32ecc5eb4dca8cee9de44ca08
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

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
