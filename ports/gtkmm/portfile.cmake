string(REGEX MATCH "^([0-9]*[.][0-9]*)" GTKMM_MAJOR_MINOR "${VERSION}")
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/gtkmm/${GTKMM_MAJOR_MINOR}/gtkmm-${VERSION}.tar.xz"
    FILENAME "gtkmm-${VERSION}.tar.xz"
    SHA512 ee40cce37c34814884ffc06e614013d23fa31cac51ea9d98ea5689a08acc2ff58bb2ca80ba822d6fe3c0f3bdcb9ce2596ede3c05c69a702b524c4e38afc3d9ab
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

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
