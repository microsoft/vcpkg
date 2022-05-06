vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

set(ATK_VERSION 2.38.0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://gitlab.gnome.org/GNOME/atk/-/archive/${ATK_VERSION}/atk-${ATK_VERSION}.tar.gz"
    FILENAME "atk-${ATK_VERSION}.tar.gz"
    SHA512 f31951ecbdace6a18fb9f772616137cb8732163b37448fef4daf1af60ba8479c94d498dcdaf4880468c80012c77a446da585926a99704a9a940b80e546080cf3
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -Dintrospection=false
    ADDITIONAL_NATIVE_BINARIES glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                               glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
    ADDITIONAL_CROSS_BINARIES   glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                               glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
)
vcpkg_install_meson()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
