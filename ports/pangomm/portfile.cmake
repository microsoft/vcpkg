# Keep distfile, don't use GitLab!
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/pangomm/2.50/pangomm-2.50.1.tar.xz"
    FILENAME "pangomm-2.50.1.tar.xz"
    SHA512 bffc55eedc4f278480a74afcf119b79a295bf5775123f582746ba425e19e2690d627baa9a9813b70db9e063db7efe959f365567dd7bcbc1fc862212ba8225a98
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dmsvc14x-parallel-installable=false
        -Dbuild-documentation=false
    ADDITIONAL_NATIVE_BINARIES glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                               glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
    ADDITIONAL_CROSS_BINARIES  glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                               glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
