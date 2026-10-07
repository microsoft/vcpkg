string(REGEX MATCH [[^[0-9][0-9]*\.[1-9][0-9]*]] VERSION_MAJOR_MINOR ${VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS
        "https://download.gnome.org/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
        "https://www.mirrorservice.org/sites/ftp.gnome.org/pub/GNOME/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
    FILENAME "GNOME-${PORT}-${VERSION}.tar.xz"
    SHA512 53e62f611f635a9df28ff805176edfd0e56b1e670ac11fdf537cf7d7b29f3584bec44b8d92c0744221082a33ae2afa9a8cfd63a655b0d250e66c57ccfde67770
)

vcpkg_extract_source_archive(SOURCE_PATH ARCHIVE "${ARCHIVE}")

set(meson_options)
if("zstd" IN_LIST FEATURES)
    list(APPEND meson_options "-Dzstd=enabled")
else()
    list(APPEND meson_options "-Dzstd=disabled")
endif()
if("brotli" IN_LIST FEATURES)
    list(APPEND meson_options "-Dbrotli=enabled")
else()
    list(APPEND meson_options "-Dbrotli=disabled")
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dautobahn=disabled
        -Ddoc_tests=false
        -Ddocs=disabled
        -Dgssapi=disabled
        -Dintrospection=disabled
        -Dntlm=disabled
        -Dpkcs11_tests=disabled
        -Dsysprof=disabled
        -Dtests=false
        -Dtls_check=false
        -Dvapi=disabled
        ${meson_options}
    ADDITIONAL_BINARIES
        "gio-querymodules = '${CURRENT_HOST_INSTALLED_DIR}/tools/glib/gio-querymodules${CMAKE_EXECUTABLE_SUFFIX}'"
        "glib-compile-schemas = '${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-schemas${CMAKE_EXECUTABLE_SUFFIX}'"
        "glib-compile-resources = '${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-resources${CMAKE_EXECUTABLE_SUFFIX}'"
        "gdbus-codegen = '${CURRENT_HOST_INSTALLED_DIR}/tools/glib/gdbus-codegen'"
        "glib-genmarshal = '${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'"
        "glib-mkenums = '${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'"
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
