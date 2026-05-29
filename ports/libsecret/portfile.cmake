string(REGEX MATCH [[^[0-9][0-9]*\.[1-9][0-9]*]] VERSION_MAJOR_MINOR ${VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS
        "https://download.gnome.org/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
        "https://www.mirrorservice.org/sites/ftp.gnome.org/pub/GNOME/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
    FILENAME "GNOME-${PORT}-${VERSION}.tar.xz"
    SHA512 f5ee1244338ba324ae403096ddd7357899f55fa9f961d2473515ac924164fe9b33f87e39eea2a30b99fc32f2300c0e626d20c98509dbbcadb2c99628a1caa0e4
)

vcpkg_extract_source_archive(SOURCE_PATH ARCHIVE "${ARCHIVE}")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dintrospection=false
        -Dgtk_doc=false
        -Dmanpage=false
        -Dvapi=false
    ADDITIONAL_BINARIES
         gdbus-codegen='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/gdbus-codegen'
         glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_tools(TOOL_NAMES secret-tool AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
