vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.gnome.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/libsoup
    REF "${VERSION}"
    SHA512 20dd9844becf4700989742aefaf9fef587a4277c982754308eb1bab21a351cac68a9066fd10ed9777d2daeb6642b06c937e5dd9ad316bd03366eae14a7576b77
    HEAD_REF main
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dtls_check=false
        -Ddocs=disabled
        -Dtests=false
        -Ddoc_tests=false
        -Dkrb5_config=false
        -Dgssapi=disabled
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
