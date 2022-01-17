vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/gtkmm/3.24/gtkmm-3.24.5.tar.xz"
    FILENAME "gtkmm-3.24.5.tar.xz"
    SHA512 8cc5aed26cc631123a5b38bc19643cf9e900beb38681b29ead9049f6b8f930f0b8ace317b8290279ab89cad85075dcb66863174082f77a2b67e4d8bd3c29de49
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        0001-build.patch
        0002-glib-timeval.patch
        0003-glib-date-month.patch
        0004-cairo-surface-format.patch
        0005-gio-application-flags.patch
        0006-signal-proxy-detailed.patch
        0007-sigc-notifiable.patch
        0008-signal-proxy1.patch
        0009-glib-refptr.patch
        0010-libsigcpp-3.patch
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Dmsvc14x-parallel-installable=false # Use separate DLL and LIB filenames for Visual Studio 2017 and 2019
        -Dbuild-tests=false
        -Dbuild-demos=false
    ADDITIONAL_NATIVE_BINARIES
        glib-compile-resources='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-resources${VCPKG_HOST_EXECUTABLE_SUFFIX}'
    ADDITIONAL_CROSS_BINARIES
        glib-compile-resources='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-resources${VCPKG_HOST_EXECUTABLE_SUFFIX}'
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
