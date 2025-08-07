vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.gnome.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/libsoup
    REF "${VERSION}"
    SHA512 8edab1f6ccf9d17befd80b238b9d435cca3743316341336b2b92e4caf5d0d5f35a05269f5ddfcbbb1839f26cd011bf13ed66ee3f620b9b0c566894cdc1600f19
    HEAD_REF main
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dgssapi=disabled
        -Dbrotli=disabled
        -Dtls_check=false
        -Dintrospection=disabled
        -Dvapi=disabled
        -Ddocs=disabled
        -Ddoc_tests=false
        -Dtests=false
        -Dautobahn=disabled
        -Dsysprof=disabled
        -Dpkcs11_tests=disabled
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
