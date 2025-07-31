string(REPLACE "." "_" appstream_glib_version "appstream_glib_${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hughsie/appstream-glib
    REF "${appstream_glib_version}"
    SHA512 720182ef507777ca818b1e955e16b1b8691927882664c1cc42e094ad10949036991ffb9a666e2f3f104cb1ca29ed824c507e9b8e46089d54b41d30b7fed0d71c
    HEAD_REF main
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Ddep11=false
        -Dbuilder=true
        -Drpm=false
        -Dalpm=false
        -Dfonts=true
        -Dman=false
        -Dgtk-doc=false
        -Dintrospection=false
    ADDITIONAL_BINARIES
        "gperf = ['${CURRENT_HOST_INSTALLED_DIR}/tools/gperf/gperf${VCPKG_HOST_EXECUTABLE_SUFFIX}']"
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
