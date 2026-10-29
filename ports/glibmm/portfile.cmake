# Glib uses winapi functions not available in WindowsStore
string(REGEX MATCH "^([0-9]*[.][0-9]*)" GLIBMM_MAJOR_MINOR "${VERSION}")
vcpkg_download_distfile(GLIBMM_ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/glibmm/${GLIBMM_MAJOR_MINOR}/glibmm-${VERSION}.tar.xz"
    FILENAME "glibmm-${VERSION}.tar.xz"
    SHA512 ac5972b9f42972aac36064a2aa2d9fd085b25836d91b3c8b06bc0fb6f6d600366d0e2d24be7d8e88fd7984c6d51b5ae4546463b502d0b73676de50931ad065f9
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${GLIBMM_ARCHIVE}"
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dbuild-examples=false
        -Dmsvc14x-parallel-installable=false
)

vcpkg_install_meson()
vcpkg_copy_pdbs()

# intentionally 2.68 - glib does not install glibmm-2.7x files
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/lib/glibmm-2.68/proc"
    "${CURRENT_PACKAGES_DIR}/lib/glibmm-2.68/proc"
)

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/COPYING"
)
