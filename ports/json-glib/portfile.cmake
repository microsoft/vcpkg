string(REGEX MATCH [[^[1-9][0-9]*\.[1-9][0-9]*]] VERSION_MAJOR_MINOR ${VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS https://download.gnome.org/sources/json-glib/${VERSION_MAJOR_MINOR}/json-glib-${VERSION}.tar.xz
    FILENAME "json-glib-${VERSION}.tar.xz"
    SHA512 e1c0e33b17333cf94beb381f505c1819090a11b616dcc23a883f231029dff277c2482823278cbf7b8a07e237d45cbfc7b05f132e1234beff609a739fd5704c6e
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dintrospection=disabled
        -Ddocumentation=disabled
        -Dtests=false
        -Dinstalled_tests=false
        -Dconformance=false
        -Dman=false
        -Dnls=disabled
    ADDITIONAL_BINARIES
        "glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'"
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSES/LGPL-2.1-or-later.txt" "${SOURCE_PATH}/LICENSES/CC0-1.0.txt" "${SOURCE_PATH}/LICENSES/MIT.txt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_tools(
    TOOL_NAMES json-glib-format json-glib-validate
    AUTO_CLEAN
)
