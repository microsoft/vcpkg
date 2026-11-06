string(REGEX MATCH [[^[0-9][0-9]*\.[1-9][0-9]*]] VERSION_MAJOR_MINOR ${VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS
        "https://download.gnome.org/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
        "https://www.mirrorservice.org/sites/ftp.gnome.org/pub/GNOME/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
    FILENAME "GNOME-${PORT}-${VERSION}.tar.xz"
    SHA512 eb4808592c8578c7541291d6528af688224eaa80ae543a68ab8a8d081d2751e44dc80b980673e412580d80d3fd4f2ff10c23dfcb63fa54b581151a7cce7f233d
)

vcpkg_extract_source_archive(SOURCE_PATH ARCHIVE "${ARCHIVE}")

set(GLIB_TOOLS_DIR "${CURRENT_HOST_INSTALLED_DIR}/tools/glib")
set(SASSC_TOOLS_DIR "${CURRENT_HOST_INSTALLED_DIR}/tools/sassc")

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Dintrospection=disabled
        -Dtests=false
        -Dgtk_doc=false
        -Dexamples=false
        -Dvapi=false
    ADDITIONAL_BINARIES
        glib-genmarshal='${GLIB_TOOLS_DIR}/glib-genmarshal'
        glib-mkenums='${GLIB_TOOLS_DIR}/glib-mkenums'
        glib-compile-resources='${GLIB_TOOLS_DIR}/glib-compile-resources${VCPKG_HOST_EXECUTABLE_SUFFIX}'
        glib-compile-schemas='${GLIB_TOOLS_DIR}/glib-compile-schemas${VCPKG_HOST_EXECUTABLE_SUFFIX}'
        sassc='${SASSC_TOOLS_DIR}/bin/sassc${VCPKG_HOST_EXECUTABLE_SUFFIX}'
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
