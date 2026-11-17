string(REGEX MATCH [[^[0-9][0-9]*\.[1-9][0-9]*]] VERSION_MAJOR_MINOR ${VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS
        "https://download.gnome.org/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
        "https://www.mirrorservice.org/sites/ftp.gnome.org/pub/GNOME/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
    FILENAME "GNOME-${PORT}-${VERSION}.tar.xz"
    SHA512 0a2ae5d86dc635df0a126f1483d917c8fd41cc0c534869ae0612291394b76fb1b2ab6ba27d2f020e123de979338a970d6653fa574d000826b4792be4c1075150
)

vcpkg_extract_source_archive(SOURCE_PATH ARCHIVE "${ARCHIVE}")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dintrospection=false
        -Dgtk_doc=false
        -Dmanpage=false
        -Dtest_setup=disabled
        -Dvapi=false
    ADDITIONAL_BINARIES
         gdbus-codegen='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/gdbus-codegen${VCPKG_HOST_EXECUTABLE_SUFFIX}'
         glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums${VCPKG_HOST_EXECUTABLE_SUFFIX}'
         glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal${VCPKG_HOST_EXECUTABLE_SUFFIX}'
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_tools(TOOL_NAMES secret-tool AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
