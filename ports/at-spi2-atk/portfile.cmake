string(REGEX MATCH [[^[0-9][0-9]*\.[1-9][0-9]*]] VERSION_MAJOR_MINOR ${VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS
        "https://download.gnome.org/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
        "https://www.mirrorservice.org/sites/ftp.gnome.org/pub/GNOME/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
    FILENAME "GNOME-${PORT}-${VERSION}.tar.xz"
    SHA512 2f40ecbc55b0fbaa57ade952a75583bc8fbfde234cce9248489e9ae06e0597d98c2f4c77d8279758dec29da97e06cde5708d30a1238d91bebd023b2320f38528
)

vcpkg_extract_source_archive(SOURCE_PATH ARCHIVE "${ARCHIVE}")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dtests=false
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
