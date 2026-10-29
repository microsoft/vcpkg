string(REGEX MATCH "^([0-9]*[.][0-9]*)" GTKMM_MAJOR_MINOR "${VERSION}")
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/gtkmm/${GTKMM_MAJOR_MINOR}/gtkmm-${VERSION}.tar.xz"
    FILENAME "gtkmm-${VERSION}.tar.xz"
    SHA512 a8ce7ba774e9d0f729cfc094df02b3f3ea76b77653f989126befa7a62130f25e56f349758f646604fc502636ca27fe247301e74690d49a8b844cee6b515b4db9
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dmsvc14x-parallel-installable=false # Use separate DLL and LIB filenames for Visual Studio 2017 and 2019
        -Dbuild-tests=false
        -Dbuild-demos=false
    ADDITIONAL_BINARIES
        glib-compile-resources='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-resources${VCPKG_HOST_EXECUTABLE_SUFFIX}'
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
