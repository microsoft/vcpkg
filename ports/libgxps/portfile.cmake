vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

string(REGEX MATCH [[^[0-9][0-9]*\.[1-9][0-9]*]] VERSION_MAJOR_MINOR ${VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS
        "https://download.gnome.org/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
        "https://www.mirrorservice.org/sites/ftp.gnome.org/pub/GNOME/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
    FILENAME "GNOME-${PORT}-${VERSION}.tar.xz"
    SHA512 d3d56e4906477b68d088bf83bde666f9ea8bf383add592772aad53dd571e727f1bc0410dd020e12212ede5ff8e26cb46150a9860a6f7af29c4d195f03e946fe9
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        libgxps-0.3.2_fix_meson_warnings.patch # https://gitlab.gnome.org/GNOME/libgxps/-/commit/a18e1260
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${OPTIONS}
        -Ddisable-introspection=true
        -Denable-test=false
        -Dwith-libjpeg=true
        -Dwith-liblcms2=true
        -Dwith-libtiff=true
)

vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES xpstojpeg xpstopdf xpstopng xpstops xpstosvg AUTO_CLEAN)

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
