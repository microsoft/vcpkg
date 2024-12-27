vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gnome.org/sources/gmime/3.2/gmime-${VERSION}.tar.xz"
    FILENAME "gmime-${VERSION}.tar.xz"
    SHA512 a60d3f9f1aa8490865c22cd9539544e9c9f3ceb4037b9749cf9e5c279f97aa88fc4cd077bf2aff314ba0db2a1b7bbe76f9b1ca5a17fffcbd6315ecebc5414a3d
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/aclocal/\"")
set(ENV{GTKDOCIZE} true)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        --disable-crypto
        --disable-glibtest
        --disable-introspection
        --disable-vala
)
vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
