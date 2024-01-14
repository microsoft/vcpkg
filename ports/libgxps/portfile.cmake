set(LIBGXPS_VERSION 0.3.2)
string(SUBSTRING ${LIBGXPS_VERSION} 0 3 MAJOR_MINOR) # e.g. 0.3

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gnome.org/sources/${PORT}/${MAJOR_MINOR}/${PORT}-${LIBGXPS_VERSION}.tar.xz"
    FILENAME "${PORT}-${LIBGXPS_VERSION}.tar.xz"
    SHA512 d3d56e4906477b68d088bf83bde666f9ea8bf383add592772aad53dd571e727f1bc0410dd020e12212ede5ff8e26cb46150a9860a6f7af29c4d195f03e946fe9
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    SOURCE_BASE ${LIBGXPS_VERSION}
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/libgxps-0.3.2_fix_meson_warnings.patch" # https://gitlab.gnome.org/GNOME/libgxps/-/commit/a18e1260
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
