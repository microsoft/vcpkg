string(REGEX MATCH "^([0-9]*[.][0-9]*)" GTKMM_MAJOR_MINOR "${VERSION}")
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/gtkmm/${GTKMM_MAJOR_MINOR}/gtkmm-${VERSION}.tar.xz"
    FILENAME "gtkmm-${VERSION}.tar.xz"
    SHA512 b0c4b77249dcf2d917919d43b04e41b819507ab34366aa4bbffd53bbe5edbb195081d69ae4996a116573a5d4e6d2affbbbc62d4ff986dcbf95045c5d64284d7f
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
