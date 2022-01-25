vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/pangomm/2.50/pangomm-2.50.0.tar.xz"
    FILENAME "pangomm-2.50.0.tar.xz"
    SHA512 844850db93b8c4dab19dd364e674ee3d61b2fcb8e020ab3d314f240065ee17aeceea21e9ddc438a7d09d56410e3f82147a57425f76bb01e26d82872934269477
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Dmsvc14x-parallel-installable=false
    ADDITIONAL_NATIVE_BINARIES glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                               glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
    ADDITIONAL_CROSS_BINARIES  glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                               glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
