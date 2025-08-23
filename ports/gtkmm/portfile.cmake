string(REGEX MATCH "^([0-9]*[.][0-9]*)" GTKMM_MAJOR_MINOR "${VERSION}")
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/gtkmm/${GTKMM_MAJOR_MINOR}/gtkmm-${VERSION}.tar.xz"
    FILENAME "gtkmm-${VERSION}.tar.xz"
    SHA512 3a7d638607197a1eb84b04be45737f7df0363b053f97c57814c1eee5d217a235bd24be72da3b69fd99d2379db130b16234fbb382b1d9a175fb35d1285c44030c
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
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
