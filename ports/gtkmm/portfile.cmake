vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/gtkmm/4.4/gtkmm-4.4.0.tar.xz"
    FILENAME "gtkmm-4.4.0.tar.xz"
    SHA512 d6f20213e9ea7a13e2b9822f220a5cdeaef9a9406abee813e0eebdb540839f25f4c19cc7669c24184bef471f5529a7897cd16ee679266148f3181dd2cfa39eb4
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Dmsvc14x-parallel-installable=false # Use separate DLL and LIB filenames for Visual Studio 2017 and 2019
        -Dbuild-tests=false
        -Dbuild-demos=false
    ADDITIONAL_NATIVE_BINARIES glib-compile-resources='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-resources${VCPKG_HOST_EXECUTABLE_SUFFIX}'
    ADDITIONAL_CROSS_BINARIES  glib-compile-resources='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-resources${VCPKG_HOST_EXECUTABLE_SUFFIX}'
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
